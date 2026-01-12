<div align="center">

# Waydroid Setup Guide for Linux

![Waydroid](https://img.shields.io/badge/Waydroid-Android_Container-3DDC84?style=for-the-badge&logo=android)
![Linux](https://img.shields.io/badge/Linux-Multiple_Distros-FCC624?style=for-the-badge&logo=linux)
![Wayland](https://img.shields.io/badge/Wayland-Required-1D99F3?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Run Android apps natively on Linux with hardware acceleration**

[Official Waydroid](https://waydro.id/) • [Documentation](https://docs.waydro.id/) • [ArchWiki](https://wiki.archlinux.org/title/Waydroid) • [GitHub](https://github.com/waydroid/waydroid)

</div>

---

## 📦 What is Waydroid?

[Waydroid](https://waydro.id/) is a rebuild of Anbox, designed to provide faster performance by utilizing more of the host system's native hardware. Unlike traditional emulation, Waydroid uses a Linux container to run Android, enabling:

- **Better Performance:** Hardware acceleration and direct GPU passthrough
- **ARM Support:** ARM and ARM64 apps work seamlessly (yes, they do!)
- **Native Integration:** Android apps appear as native Linux applications
- **Lightweight:** Container-based instead of full VM emulation
- **Multiple Architecture Support:** Works on ARM, ARM64, x86, and x86_64

For official documentation, check out [docs.waydro.id](https://docs.waydro.id/) and [ArchWiki Waydroid](https://wiki.archlinux.org/title/Waydroid)

---

## ✅ Prerequisites

### 1. Wayland Session Manager
**Required:** Waydroid only works in Wayland sessions (not X11).

Check if you're running Wayland:
```bash
echo $XDG_SESSION_TYPE
```

If it returns `x11`, you have options:
- Switch to a Wayland desktop environment (GNOME, KDE Plasma 6+, etc.)
- Run a nested Wayland session (e.g., Weston) within X11

### 2. Supported Hardware

#### CPUs
Waydroid supports: ARM, ARM64, x86, and x86_64 architectures on most platforms.

#### GPUs
- **Intel/AMD GPUs:** Full hardware acceleration supported via Mesa
- **Nvidia GPUs (non-Tegra):** Use software rendering (see [Troubleshooting](#-troubleshooting))
- **VMs:** Use software rendering
- **Hybrid Setup (Integrated + Dedicated GPU):** Can select which GPU to use with Waydroid-Settings

### 3. Kernel with Binder Modules

Your kernel must include binder module support. Choose **one** of the following:

#### Option A: Use a kernel with built-in binder support (Recommended)

**Available kernels:**
- **linux-zen** (Arch Linux default)
- **linux-cachyos** or **linux-cachyos-lts** (CachyOS, available in chaotic-aur)
- **linux-xanmod** (available in chaotic-aur)

**Install via:**
```bash
# GUI method (Garuda users)
Garuda Settings Manager → Hardware → Kernel

# CLI method - Example for linux-xanmod
sudo pacman -S linux-xanmod linux-xanmod-headers
```

**For linux-xanmod kernel, enable PSI:**
```bash
# Edit GRUB configuration
sudo nano /etc/default/grub

# Add psi=1 to GRUB_CMDLINE_LINUX_DEFAULT
# Example: GRUB_CMDLINE_LINUX_DEFAULT="... psi=1"

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot
sudo reboot
```

#### Option B: Install binder_linux-dkms (for stock kernels)

Use this if your kernel doesn't have built-in binder support:
```bash
sudo pacman -S binder_linux-dkms
```

#### Verify binder modules are available:
```bash
# Test if binder module loads
sudo modprobe -a binder

# or try
sudo modprobe -a binder_linux

# If the command returns with no output, your kernel has binder support
```

---

## 🚀 Quick Installation

### Automated Installation (Recommended)

Use the provided installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/dougbug589/waydroid-guide-cachyos-arch/main/install-waydroid.sh -o install-waydroid.sh
chmod +x install-waydroid.sh
sudo ./install-waydroid.sh
```

The script automates:
- Waydroid installation
- Binder modules and binderfs setup
- Service configuration and enablement
- Optional GApps and ARM translation installation
- Auto-start launcher setup
- File sharing configuration

### Manual Installation

If you prefer manual setup, continue to the **[Manual Installation & Setup](#-manual-installation--setup)** section below.

---

## 💻 System Information

This guide covers:
- **Distributions:** Arch Linux, Garuda, CachyOS, EndeavourOS, and other Arch-based distros
- **Desktop Environments:** KDE Plasma, GNOME, and others (any with Wayland support)
- **GPU Configurations:** Intel, AMD, and Nvidia

Tested with:
- CachyOS with linux-cachyos kernel
- KDE Plasma on Wayland
- Various GPU setups

---

## 📥 Manual Installation & Setup

### Step 1: Install Waydroid Package

Update your system and install Waydroid:

```bash
sudo pacman -Syu waydroid
```

For CachyOS or systems with chaotic-aur:
```bash
sudo pacman -S waydroid
```

### Step 2: Initialize Waydroid

Choose your initialization method:

**Basic initialization (no Google Play Store):**
```bash
sudo waydroid init
```

**With Google Play Store (GApps):**
```bash
sudo waydroid init -s GAPPS
```

**Force clean initialization (if re-installing):**
```bash
sudo waydroid init -f
# or with GApps
sudo waydroid init -s GAPPS -f
```

The `waydroid init` command performs these steps:
- Downloads the latest Android image from Waydroid repository
- Sets up Waydroid configuration file
- Configures runtime environment
- Initializes the container

> ⚠️ **Note:** Download speeds may be slow. If this occurs:
> - Try connecting via VPN to a European server
> - [Riseup-VPN](https://riseup.net/) is available in chaotic-aur: `sudo pacman -S riseup-vpn`

### Step 3: Configure and Enable Services

```bash
# Enable and start the container service
sudo systemctl enable --now waydroid-container.service
sudo systemctl enable --now waydroid-container.socket

# Prevent container from auto-freezing
sudo systemctl mask waydroid-container-freeze.timer

# Reboot to ensure all configurations are loaded
sudo reboot
```

### Step 4: Start Waydroid Session

**Recommended approach with systemctl:**

Terminal:
```bash
# Start the container
sudo systemctl start waydroid-container

# Start the session
waydroid session start

# Wait for: "Android with user 0 is ready"
```

**Alternative approach without systemctl:**

Terminal 1:
```bash
sudo waydroid container start
```

Terminal 2 (after container starts):
```bash
waydroid session start
```

### Step 5: Launch Waydroid

Once the session shows "Android with user 0 is ready", launch Waydroid:

```bash
# Normal windowed mode
waydroid show-full-ui

# Full-screen mode (same command)
waydroid show-full-ui
```

You can now launch Android apps from your application menu.

### Step 6: Keep Waydroid Updated

Regularly upgrade to the latest version:

```bash
sudo waydroid upgrade
```

---

## ⚠️ Common Issues & Solutions

### Binder Module Issues

#### Issue: binder modules not loading

Check if binder is loaded:
```bash
lsmod | grep binder
```

Manually load modules:
```bash
sudo modprobe binder_linux
sudo modprobe ashmem_linux
```

Verify Android kernel configuration:
```bash
zgrep ANDROID /proc/config.gz
```

#### Mounting binderfs

If you have issues with binder, mount binderfs:

```bash
# Mount binderfs
sudo mount -t binder binder /dev/binderfs

# Verify it's mounted
ls /dev/binderfs
mount | grep binder
```

**Make binderfs mount persistent** by creating `/etc/systemd/system/binderfs.service`:

```ini
[Unit]
Description=Mount binderfs for Waydroid
DefaultDependencies=no
Before=waydroid-container.service

[Service]
Type=oneshot
ExecStart=/usr/bin/mount -t binder binder /dev/binderfs
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable the service:
```bash
sudo systemctl enable binderfs.service
```

### PSI Warning ([gbinder] WARNING: Service manager /dev/binder has died)

If you see binder errors, enable PSI by default:

```bash
# Edit GRUB configuration
sudo nano /etc/default/grub

# Add psi=1 to GRUB_CMDLINE_LINUX_DEFAULT
# Example: GRUB_CMDLINE_LINUX_DEFAULT="... psi=1"

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot
sudo reboot
```

### Complete Reset

If you encounter persistent errors after changing kernels or have made too many modifications:

```bash
# Stop all Waydroid processes
waydroid session stop
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container
sudo pkill -f waydroid

# Check for remaining processes
ps aux | grep waydroid

# Clean up all Waydroid data and cache
rm -rf ~/.cache/waydroid
rm -rf ~/.local/share/waydroid
sudo rm -rf /run/waydroid
sudo rm -rf /usr/share/waydroid-extra

# Reinstall Waydroid
sudo pacman -S waydroid

# Start fresh
sudo waydroid init -f
sudo systemctl enable --now waydroid-container
waydroid session start
```

### Network Issues

If Waydroid container can't access the network, configure UFW firewall:

```bash
# Allow DNS
sudo ufw allow 53

# Allow DHCP
sudo ufw allow 67

# Allow container forwarding
sudo ufw default allow FORWARD
```

> ⚠️ **Warning:** The `allow FORWARD` rule affects your firewall's forwarding policy. Be aware of the security implications.

### GPU/Rendering Issues

#### Force Software Rendering

If you have Nvidia GPU or VM issues:

```bash
# Edit Waydroid base properties
sudo nano /var/lib/waydroid/waydroid_base.prop

# Add or modify this line
WAYDROID_USE_SWVENC=1
```

#### Roblox and Games Running in Rotated Mode

For Roblox and similar games that display rotated:

```bash
# Edit Waydroid base configuration
sudo nano /var/lib/waydroid/waydroid_base.prop

# Change GPU rendering backend
# FROM:
# ro.hardware.gralloc=gbm
# TO:
ro.hardware.gralloc=minigbm_gbm_mesa
```

Then restart Waydroid:
```bash
waydroid session stop
waydroid session start
```

For fullscreen windowed apps, press `F11` to switch to windowed mode.

---

## 📱 Installing Google Play Store & ARM Support

You need two things for full app compatibility:
1. **GApps:** Google Play Store and Google services
2. **ARM Translation:** Library to run ARM-only apps on x86/x86_64

### Method 1: Using waydroid-helper (GUI) - Recommended

Install and run the graphical tool:

```bash
# Install from official repos or chaotic-aur
sudo pacman -S waydroid-helper

# Or download AppImage from GitHub releases
# https://github.com/waydroid-helper/waydroid-helper
```

Then launch from your application menu and install:
- Your preferred GApps version (OpenGapps, MindTheGapps, LiteGapps)
- ARM translation library (libndk or libhoudini)

### Method 2: Using waydroid-script (CLI)

Install the interactive script tool:

```bash
# Install from official repos or chaotic-aur
sudo pacman -S waydroid-script-git

# Run the interactive menu
sudo waydroid-extras
```

Choose options to install:
- **GApps packages:**
  - OpenGapps: Standard Google Apps implementation
  - MindTheGapps: Minimal, optimized for custom ROMs (better for Android 13)
  - LiteGapps: Minimal, lightweight version
  
- **ARM Translation Libraries:**
  - **libndk** (Google Chromiumos): Better performance on AMD GPUs
  - **libhoudini** (Intel): Better performance on Intel CPUs

> **Tip:** Test both libraries if you have performance issues. Only one can be active at a time (last installed overwrites previous).

### Method 3: Direct Installation from Repos

Install pre-built GApps image:

```bash
# Option 1: From chaotic-aur
sudo pacman -S waydroid-image-gapps

# Option 2: Reinitialize Waydroid with GApps
sudo waydroid init -s GAPPS -f

# Restart container to see changes
sudo systemctl restart waydroid-container
```

### Register Device with Google

To use Google Play Store, you must register your device:

#### Using waydroid-script:

```bash
# Start Waydroid session first
waydroid session start

# In another terminal
sudo waydroid-extras

# Select: "Get Google Device ID to Get Certified"
# Copy the returned numeric ID
# Open: https://google.com/android/uncertified/?pli=1
# Enter your device ID and submit
# Wait 10-20 minutes for registration
# Clear Google Play Service cache and login
```

#### Manual device registration:

Within Waydroid, use the Google Account Management settings to register.

### Install Open-Source App Stores

If you can't access Play Store or prefer open-source alternatives:

- **[F-Droid](https://f-droid.org/):** Open-source app repository
  - Download APK: https://f-droid.org/
  - Install: `waydroid app install f-droid.apk`

- **[Aurora Store](https://auroraoss.com/):** Unofficial Play Store client
  - Download from GitHub releases
  - Install: `waydroid app install aurora.apk`

- **[microG Project](https://microg.org/):** Open-source Google services replacement

---

## 📂 File Sharing Between Linux and Android

### Quick Setup

Create a shared folder accessible from both systems:

```bash
# Create Linux folder
mkdir -p ~/SharedWithAndroid

# Create mount point in Waydroid storage
sudo mkdir -p ~/.local/share/waydroid/data/media/0/SharedFolder

# Bind mount the folder
sudo mount --bind ~/SharedWithAndroid ~/.local/share/waydroid/data/media/0/SharedFolder

# Verify mount
mount | grep SharedFolder
```

Files in `~/SharedWithAndroid` are now accessible at `/sdcard/SharedFolder` inside Waydroid.

### Make File Sharing Permanent

Add to `/etc/fstab` (replace `YOUR_USERNAME` with your actual username):

```
/home/YOUR_USERNAME/SharedWithAndroid /home/YOUR_USERNAME/.local/share/waydroid/data/media/0/SharedFolder none bind 0 0
```

Example for user `mak`:
```
/home/mak/SharedWithAndroid /home/mak/.local/share/waydroid/data/media/0/SharedFolder none bind 0 0
```

Then reload fstab:
```bash
sudo mount -a
```

---

## 🚀 Auto-Start Waydroid Without Password

### Create Startup Script

Create `/usr/local/bin/start-waydroid.sh`:

```bash
#!/bin/bash
# Start Waydroid container and session
sudo systemctl start waydroid-container.service
waydroid session start
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/start-waydroid.sh
```

### Allow systemctl Without Password

Edit sudoers file:

```bash
EDITOR=nano sudo visudo
```

Add this line (**replace `YOUR_USERNAME`** with your actual username):

```
YOUR_USERNAME ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service
```

Example for user `mak`:
```
mak ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service
```

### Create Desktop Launcher

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
Categories=Utility;
```

Make it executable:
```bash
chmod +x ~/.local/share/applications/waydroid-start.desktop
update-desktop-database ~/.local/share/applications/
```

Now you can start Waydroid from your application menu!

### Auto-Start with Shizuku (Optional)

For easier root-level app permissions without full root:

```bash
# Install Shizuku from Play Store or F-Droid
# Then establish ADB connection
sudo waydroid shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
```

Create an alias to automate this:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias waydroid-start='waydroid show-full-ui & sleep 10 && pkexec waydroid shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
```

Adjust the sleep duration (10 seconds) based on your system's startup time.

---

## 🔧 Advanced Configuration

### Root Access Options

#### Option 1: Magisk (Xanmod Kernel Only)

```bash
# Install via waydroid-extras
sudo waydroid-extras

# Select: Magisk Delta
# Follow on-screen instructions
```

For detailed Magisk setup:
- https://github.com/casualsnek/waydroid_script#install-magisk
- https://github.com/nitanmarcel/waydroid-magisk

#### Option 2: Shizuku (All Kernels) - Recommended

Shizuku provides ADB-level permissions without full root:

1. Install from [Play Store](https://play.google.com/store/apps/details?id=moe.shizuku.privileged.api) or [F-Droid](https://f-droid.org/en/packages/moe.shizuku.privileged.api/)
2. Establish ADB connection from Linux:
   ```bash
   sudo waydroid shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
   ```
3. Apps can now request ADB permissions instead of full root

> Works with **all kernels** and covers ~99% of root-required use cases.

### Input Mapping for Games

Use these tools to map keyboard and mouse to game controls:

#### Option 1: XtMapper

Download APK from [GitHub releases](https://github.com/Xtr126/XtMapper/releases)

```bash
waydroid app install XtMapper.apk
```

#### Option 2: Key Mapper

Available in [F-Droid](https://f-droid.org/) and Play Store

```bash
# Via F-Droid
waydroid app install keymapper.apk
```

> **Tip:** Tested with games like Need for Speed: No Limits with zero input lag!

### Additional Tools

Install via `waydroid-extras` or `waydroid-helper`:

- **Smart Dock:** Modern, customizable desktop mode launcher
- **Widevine DRM:** For streaming video apps
- **LiteGapps:** Minimal Google Apps package
- **Magisk Delta:** Android customization suite
- **microG:** Open-source Google services replacement

### GPU Selection (Dual GPU Systems)

Use Waydroid-Settings to select which GPU to use:

```bash
sudo pacman -S waydroid-settings

# Launch from application menu
```

> Works with systems having both integrated and dedicated GPUs.

---

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

# Open Waydroid shell
sudo waydroid shell

# Stop Waydroid session
waydroid session stop

# Stop container
sudo systemctl stop waydroid-container

# Restart everything
sudo systemctl restart waydroid-container
waydroid session start

# View Waydroid logs
journalctl -u waydroid-container -f

# Check Android version
waydroid shell getprop ro.build.version.release
```

---

## 📚 Resources & Further Reading

- **[Official Waydroid Documentation](https://docs.waydro.id/)**
- **[ArchWiki - Waydroid](https://wiki.archlinux.org/title/Waydroid)**
- **[Waydroid GitHub Repository](https://github.com/waydroid/waydroid)**
- **[Waydroid Script](https://github.com/casualsnek/waydroid_script)** - GApps and ARM translation
- **[Waydroid Helper](https://github.com/waydroid-helper/waydroid-helper)** - GUI configuration tool
- **[Roblox on Waydroid Guide](https://gitlab.com/TestingPlant/roblox-on-waydroid-guide/)**
- **[CachyOS Wiki](https://wiki.cachyos.org/)**

---

## 💡 Key Takeaways

- Waydroid requires **Wayland** - it won't work on X11
- Your kernel must have **binder module support**
- **GApps + ARM translation** are essential for most apps
- **File sharing** is easy with bind mounts
- **Shizuku** provides root-like permissions without actual root access
- Regular updates via `sudo waydroid upgrade` are important
- Most troubleshooting issues are solved by reinitializing with `-f` flag

---

## 🤝 Contributing

Found an issue or have improvements? Please:
- Check [existing issues](https://github.com/waydroid/waydroid/issues)
- Review [Waydroid troubleshooting docs](https://docs.waydro.id/troubleshooting)
- Test your solution before reporting

Share your experience, apps that work, and games you got running!

---

**Last Updated:** January 2026

> **⚠️ Disclaimer:** This is a community guide based on extensive personal experience, not official Waydroid documentation. Always review commands before running them. Your setup may vary depending on hardware, kernel, and distribution.
