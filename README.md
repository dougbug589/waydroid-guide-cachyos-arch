<div align="center">

# My Waydroid Setup on CachyOS

![CachyOS](https://img.shields.io/badge/CachyOS-6.18.5--2-blue?style=for-the-badge&logo=arch-linux)
![Waydroid](https://img.shields.io/badge/Waydroid-Android-3DDC84?style=for-the-badge&logo=android)
![KDE](https://img.shields.io/badge/KDE_Plasma-Wayland-1D99F3?style=for-the-badge&logo=kde)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Run Android apps like native Linux apps - no GUI needed**

[Official Waydroid](https://waydro.id/) • [Documentation](https://docs.waydro.id/) • [CachyOS](https://cachyos.org/)

</div>

---

This is how I got [Waydroid](https://waydro.id/) working on [CachyOS](https://cachyos.org/) Linux. It's not a comprehensive guide, just my process with the stuff that actually worked for me.

---

## 📦 What is Waydroid?

[Waydroid](https://waydro.id/) lets you run Android apps on Linux without the overhead of emulation. It uses containers, so it's fast and integrates well with your desktop.

For official documentation, check out [docs.waydro.id](https://docs.waydro.id/)

## ✅ Prerequisites

- [CachyOS](https://cachyos.org/) Linux (or any [Arch](https://archlinux.org/)-based distro)
- Running a [Wayland](https://wayland.freedesktop.org/) session (not X11)
- Good news: CachyOS kernel already has binder modules built-in

## 💻 My Setup

- **Desktop Environment:** [KDE Plasma](https://kde.org/plasma-desktop/) (Wayland)
- **Kernel:** 6.18.5-2-cachyos
- **Use Case:** Running Android apps directly from the app menu without opening Waydroid's GUI

## 📥 Installation

Install Waydroid from the official repos:

```bash
sudo pacman -S waydroid
```

## ⚙️ Initial Setup

The basic setup is straightforward:

```bash
# Initialize Waydroid
sudo waydroid init -f

# Enable and start the container service and socket
sudo systemctl enable --now waydroid-container.service
sudo systemctl enable --now waydroid-container.socket

# Prevent container from auto-freezing (important!)
sudo systemctl mask waydroid-container-freeze.timer

# Start a Waydroid session
waydroid session start

# Launch the UI
waydroid show-full-ui
```

## ⚠️ Issues I Ran Into

### Binder Modules

Even though CachyOS has binder support built-in, I had to manually load the modules and mount binderfs:

```bash
# Check if binder is loaded
lsmod | grep binder

# If not, load them manually
sudo modprobe binder_linux
sudo modprobe ashmem_linux

# Check kernel config for Android support
zgrep ANDROID /proc/config.gz

# Mount binderfs (this was crucial for me)
sudo mount -t binder binder /dev/binderfs

# Verify it's mounted
ls /dev/binderfs
mount | grep binder
```

The binderfs mount was the key step that made everything work properly.

### Clean Slate After Trial and Error

After messing around with different things, I had to do a complete reset. I even reinstalled Waydroid from the official repos instead of AUR:

```bash
# Stop everything
waydroid session stop
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container
sudo pkill -f waydroid

# Check for any remaining processes
ps aux | grep waydroid

# Clean up all Waydroid data
rm -rf ~/.cache/waydroid
rm -rf ~/.local/share/waydroid
sudo rm -rf /run/waydroid
sudo rm -rf /usr/share/waydroid-extra

# Reinstall from official repos (if you had AUR version)
yay -Rns waydroid
sudo pacman -S waydroid

# Start fresh
sudo waydroid init -f
sudo systemctl enable --now waydroid-container
waydroid session start
```

### 🔥 Firewall Configuration

I use UFW and needed to allow some ports for Waydroid networking:

```bash
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
```

## 📱 Installing Google Apps and ARM Support

I used [waydroid_script](https://github.com/casualsnek/waydroid_script) to add GApps and ARM translation:

```bash
# Clone and setup
git clone https://github.com/casualsnek/waydroid_script
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt

# Run the script (use menu to install GApps and ARM support)
sudo venv/bin/python3 main.py
```

## 📂 File Sharing with Android

To share files between Linux and Android, I created a bind mount:

```bash
# Create a folder in your home directory
mkdir -p ~/Downloads/waydroid

# Create the target directory in Waydroid's storage
sudo mkdir -p ~/.local/share/waydroid/data/media/0/waydroid

# Mount it to Android's storage
sudo mount --bind ~/Downloads/waydroid ~/.local/share/waydroid/data/media/0/waydroid

# Check if it's mounted
mount | grep waydroid
```

Now files in `~/Downloads/waydroid` are accessible from Android in the `/sdcard/waydroid` folder.

## 🚀 Auto-Start Without Password

This is my favorite part - I created a launcher that starts Waydroid without needing sudo password every time.

### Create the startup script

Create `/usr/local/bin/start-waydroid.sh`:

```bash
#!/bin/bash
# Start Waydroid container & session
systemctl start waydroid-container.service
waydroid session start
```

Make it executable:

```bash
sudo chmod +x /usr/local/bin/start-waydroid.sh
```

### Create desktop entry

Create `~/.local/share/applications/waydroid-start.desktop`:

```ini
[Desktop Entry]
Name=Start Waydroid
Comment=Start Waydroid container and session
Exec=/usr/local/bin/start-waydroid.sh
Icon=waydroid
Type=Application
Terminal=false
StartupNotify=true
```

Make it executable:

```bash
chmod +x ~/.local/share/applications/waydroid-start.desktop
update-desktop-database ~/.local/share/applications/
```

### Allow systemctl without password

Edit sudoers file:

```bash
EDITOR=nano sudo visudo
```

Add this line (replace `YOUR_USERNAME` with your actual username):

```
YOUR_USERNAME ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service
```

Now you can start Waydroid from your application menu, and once it's running, you can launch Android apps directly without opening the full UI.

## 🛠️ Useful Commands

```bash
# Check Waydroid status
waydroid status

# List installed Android apps
waydroid app list

# Install an APK
waydroid app install /path/to/app.apk

# Launch specific app
waydroid app launch com.package.name

# Stop Waydroid session
waydroid session stop

# Restart container
sudo systemctl restart waydroid-container
```

## 💡 What I Learned

- CachyOS kernel already has binder support, no need for dkms modules
- Sometimes you just need to nuke everything and start fresh
- The auto-start setup makes Waydroid feel like a native app launcher
- File sharing via bind mounts is super convenient
- waydroid_script is essential for GApps and ARM app support
- Most troubleshooting ended up being Android-side stuff (Google sign-in, app permissions) rather than installation issues

## 📚 Resources

- [Waydroid Docs](https://docs.waydro.id/)
- [Waydroid Script](https://github.com/casualsnek/waydroid_script)
- [CachyOS Wiki](https://wiki.cachyos.org/)
- [Arch Wiki - Waydroid](https://wiki.archlinux.org/title/Waydroid)

---

Last updated: January 2026
