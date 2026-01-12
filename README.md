<div align="center">

# Complete Waydroid Setup Guide for Linux

![Waydroid](https://img.shields.io/badge/Waydroid-Android_Container-3DDC84?style=for-the-badge&logo=android)
![Linux](https://img.shields.io/badge/Linux-Arch_Based-FCC624?style=for-the-badge&logo=linux)
![Wayland](https://img.shields.io/badge/Wayland-Required-1D99F3?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Run Android natively on Linux with hardware acceleration - Complete, beginner-friendly guide**

[Official Waydroid](https://waydro.id/) • [Documentation](https://docs.waydro.id/) • [ArchWiki](https://wiki.archlinux.org/title/Waydroid) • [GitHub](https://github.com/waydroid/waydroid)

</div>

---

## 📦 What is Waydroid?

**Waydroid** (formerly Anbox-Halium) is a rebuild of Anbox designed to provide **significantly faster performance** by utilizing more of the native host's hardware instead of pure emulation.

### Key Benefits:
- ✅ **ARM apps work perfectly** - Including games and native ARM-only applications
- ✅ **Hardware acceleration** - Direct GPU passthrough for Intel, AMD, Tegra
- ✅ **Container-based** - Lightweight Linux container, not a full VM
- ✅ **Native integration** - Android apps appear in your application menu
- ✅ **Better performance** - Rebuilds Anbox with native hardware support

**Source:** [waydro.id](https://waydro.id/) | [ArchWiki](https://wiki.archlinux.org/title/Waydroid) | [GitHub](https://github.com/waydroid/waydroid)

---

## 🔧 Comprehensive Prerequisites

### 1. Wayland Session (Required)

Waydroid **only works in Wayland sessions**, not X11.

**Check your session type:**
```bash
echo $XDG_SESSION_TYPE
```

Expected output: `wayland`

**If you're on X11:**
- Switch to a Wayland desktop environment (GNOME, KDE Plasma 6+, etc.)
- Or run a nested Wayland session inside X11 (simplest: [Weston](https://wayland.freedesktop.org/releases/weston-12.0.0.tar.xz))

### 2. Supported Hardware

#### CPUs Supported
- **ARM** (mobile processors)
- **ARM64** (newer mobile processors)
- **x86** (older Intel/AMD)
- **x86_64** (modern Intel/AMD) ← Most common

#### GPUs Supported
Waydroid uses **Android's Mesa integration** for GPU passthrough.

| GPU Type | Support | Notes |
|----------|---------|-------|
| **Intel iGPU** | ✅ Full acceleration | Works great with Mesa |
| **AMD iGPU/dGPU** | ✅ Full acceleration | Works great with Mesa |
| **Nvidia (non-Tegra)** | ⚠️ Software rendering only | Use GPU forcing guide in troubleshooting |
| **Nvidia Tegra** | ✅ Full acceleration | Mobile-focused Nvidia |
| **Virtual Machines** | ⚠️ Software rendering | Use software rendering mode |
| **Hybrid GPU (Intel+Nvidia, AMD+Nvidia)** | ✅ Selective acceleration | Use Waydroid-Settings to choose GPU |

**Nvidia GPU Note:** If you have both Nvidia dedicated GPU and Intel/AMD integrated GPU, use [Waydroid-Settings](#waydroid-settings-gpu-selection) to route graphics through the integrated GPU.

### 3. Kernel with Binder Module Support (Critical)

Your kernel must include **binder module support**. This is essential for Android container functionality.

#### Option A: Install Kernel with Built-in Binder (Recommended)

Choose **one** of these kernels (all include binder modules):

**1) linux-zen** (Arch Linux default)
```bash
sudo pacman -S linux-zen linux-zen-headers
```

**2) linux-cachyos** or **linux-cachyos-lts** (CachyOS optimized)
```bash
# Install from chaotic-aur
sudo pacman -S linux-cachyos linux-cachyos-headers
# or LTS version
sudo pacman -S linux-cachyos-lts linux-cachyos-lts-headers
```

**3) linux-xanmod** (High performance, best for games)
```bash
# Install from chaotic-aur
sudo pacman -S linux-xanmod linux-xanmod-headers
```

**GUI Installation (Garuda users):**
```
Garuda Settings Manager → Hardware → Kernel
```

**For CachyOS kernel selection:**
```bash
# View available kernels
sudo pacman -Ss cachyos-kernel

# Install your choice
sudo pacman -S linux-cachyos linux-cachyos-headers
```

#### Important: PSI Configuration for linux-xanmod

If using **linux-xanmod**, enable PSI (Pressure Stall Information):

```bash
# Edit GRUB configuration
sudo nano /etc/default/grub

# Find the line starting with GRUB_CMDLINE_LINUX_DEFAULT
# Add psi=1 to the end (before any # symbols)

# Example - change this:
# GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
# To this:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot
sudo reboot
```

#### Option B: Use Stock Kernel + binder_linux-dkms

If using Arch's stock kernel or another kernel without binder:

```bash
sudo pacman -S binder_linux-dkms
```

This installs binder modules via DKMS (automatically built for your kernel).

#### Verify Binder Module Support

**Test if binder is available:**
```bash
# Try loading binder module
sudo modprobe -a binder

# Or with alternate name
sudo modprobe -a binder_linux

# If no error output, you're good!
# If error "module not found", install binder_linux-dkms
```

**Check kernel Android config:**
```bash
zgrep ANDROID /proc/config.gz
```

Look for: `CONFIG_ANDROID=y`

---

## 📋 Complete Dependencies & Packages

### Required Packages

```bash
# Core Waydroid
sudo pacman -S waydroid

# If not using kernel with built-in binder
sudo pacman -S binder_linux-dkms

# Firewall (if using UFW)
sudo pacman -S ufw
```

### Recommended Packages

```bash
# GApps and ARM translation helper (GUI)
sudo pacman -S waydroid-helper

# GApps and ARM translation helper (CLI)
sudo pacman -S waydroid-script-git

# System utilities
sudo pacman -S android-tools  # adb, fastboot
sudo pacman -S android-udev   # Device rules

# GPU settings manager
sudo pacman -S waydroid-settings

# VPN (if slow downloads)
sudo pacman -S riseup-vpn

# Text editors (for config editing)
sudo pacman -S nano  # or vim, nano, gedit, etc.
```

### Optional Packages for Enhanced Functionality

```bash
# App stores
waydroid app install f-droid.apk
waydroid app install aurora-store.apk

# Key mapper for games
waydroid app install keymapper.apk    # From F-Droid
waydroid app install xtmapper.apk     # From GitHub

# Root-like functionality
waydroid app install shizuku.apk      # Install from Play Store or F-Droid

# Android customization
waydroid app install magisk.apk       # Requires linux-xanmod kernel
```

---

## 🚀 Installation & Setup

### Step 1: Update System

```bash
sudo pacman -Syu
```

### Step 2: Install Waydroid Package

```bash
sudo pacman -S waydroid
```

For CachyOS users (from chaotic-aur):
```bash
# Waydroid is in chaotic-aur
sudo pacman -S waydroid
```

### Step 3: Initialize Waydroid

**Basic initialization:**
```bash
sudo waydroid init
```

**With Google Play Store (GApps):**
```bash
sudo waydroid init -s GAPPS
```

**Force reinitialize (clean slate):**
```bash
sudo waydroid init -f
# or with GApps
sudo waydroid init -s GAPPS -f
```

**What `waydroid init` does:**
1. Downloads latest Android image from Waydroid repository
2. Sets up Waydroid configuration file (specifies image location, runtime, settings)
3. Configures runtime environment
4. Initializes the container

> ⚠️ **Slow Downloads:** If downloads are very slow, use a VPN connected to Europe (many report better speeds).
> Install via: `sudo pacman -S riseup-vpn` or use other VPN services.

### Step 4: Setup Kernel Modules (if needed)

**Load binder modules manually:**
```bash
sudo modprobe binder_linux
sudo modprobe ashmem_linux
```

**Mount binderfs:**
```bash
sudo mkdir -p /dev/binderfs
sudo mount -t binder binder /dev/binderfs

# Verify
mount | grep binder
ls /dev/binderfs
```

**Make binderfs persistent** by creating `/etc/systemd/system/binderfs.service`:

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

Enable it:
```bash
sudo systemctl enable binderfs.service
```

### Step 5: Enable and Start Services

```bash
# Enable and start container service
sudo systemctl enable --now waydroid-container.service
sudo systemctl enable --now waydroid-container.socket

# Prevent automatic freezing
sudo systemctl mask waydroid-container-freeze.timer

# Reboot to ensure everything loads
sudo reboot
```

### Step 6: Start Waydroid Session

**With systemctl (recommended):**
```bash
# Terminal 1: Start container
sudo systemctl start waydroid-container

# Terminal 2: Start session
waydroid session start

# Wait for: "Android with user 0 is ready"
```

**Without systemctl:**
```bash
# Terminal 1
sudo waydroid container start

# Terminal 2 (wait for container to start)
waydroid session start
```

### Step 7: Launch Waydroid UI

Once session shows "Android with user 0 is ready":

```bash
# Launch Waydroid
waydroid show-full-ui

# Full-screen mode (same command, press F11 in-app to toggle fullscreen)
waydroid show-full-ui
```

### Step 8: Keep Updated

```bash
sudo waydroid upgrade
```

---

## 📱 Installing GApps and ARM Translation

### What You Need

For full app compatibility, install:

1. **GApps** (Google Play Store + Google services)
2. **ARM Translation Library** (to run ARM-only apps on x86/x86_64)

### Method 1: waydroid-helper GUI (Easiest)

**Install:**
```bash
sudo pacman -S waydroid-helper
# or download AppImage from GitHub
```

**Launch from application menu and install:**
- Your preferred **GApps version:**
  - **OpenGapps** - Standard, full-featured Google Apps
  - **MindTheGapps** - Minimal, optimized (recommended for Android 13+)
  - **LiteGapps** - Lightweight, minimal
  
- Your preferred **ARM Translation:**
  - **libndk** (Google Chromiumos) - Better on AMD GPUs
  - **libhoudini** (Intel) - Better on Intel CPUs

> **Tip:** Only one ARM translation can be active (last installed overwrites previous)

### Method 2: waydroid-script CLI (Interactive Menu)

**Install:**
```bash
sudo pacman -S waydroid-script-git
```

**Run interactive menu:**
```bash
sudo waydroid-extras
```

**Choose from menu:**
- GApps packages (OpenGapps, MindTheGapps, LiteGapps)
- ARM translation (libndk, libhoudini)
- Magisk (requires linux-xanmod kernel)
- microG (open-source Google services)
- Smart Dock (desktop launcher)
- Widevine DRM (for streaming)

**Android 13+ Compatibility Notes:**

For **Android 13 ROMs**, special considerations:
- **GApps:** Use **MindTheGapps** (designed for Android 13+)
- **ARM Translation:** Use **ndk_translation-chromeos_zork** for best compatibility

Check your Android version:
1. Open Waydroid Settings app
2. Go to About phone
3. Note the Android version

### Method 3: Direct Installation from Repos

```bash
# Install pre-built GApps image
sudo pacman -S waydroid-image-gapps

# Or reinitialize with GApps
sudo waydroid init -s GAPPS -f

# Restart container
sudo systemctl restart waydroid-container
```

### Step-by-Step ARM Translation Comparison

| Feature | libndk | libhoudini |
|---------|--------|-----------|
| **Creator** | Google (Chromiumos) | Intel |
| **Better on** | AMD GPUs | Intel CPUs |
| **Performance (AMD)** | ✅ Excellent | ⚠️ Frame drops |
| **Performance (Intel)** | ✅ Good | ✅ Better |
| **Tested with** | Games, apps | Games, apps |
| **Android 13** | ✅ Recommended | ⚠️ Check compatibility |

**Performance Test Example:** Angry Birds
- On AMD with libhoudini: Frame drops, touch lag
- On AMD with libndk: Perfect performance

### Device Registration with Google

To use Google Play Store, you must register your Waydroid device with Google.

**Method A: Using waydroid-script**

```bash
# Start Waydroid session
waydroid session start

# In another terminal
sudo waydroid-extras

# Select: "Get Google Device ID to Get Certified"
# Copy the returned numeric ID
# Open: https://google.com/android/uncertified/?pli=1
# Paste your device ID and submit registration
# Wait 10-20 minutes for registration confirmation
```

After registration:
```bash
# Clear Google Play Services cache
waydroid shell pm clear com.google.android.gms

# Try logging in to Play Store
```

**Method B: Manual Registration**

Within Waydroid Settings, use Google Account Management to register device directly.

**Method C: Without waydroid-script**

Check Waydroid documentation for manual registration steps.

---

## 🔐 Root Access & Permissions

### Option 1: Magisk (Full Root) ⚠️ Xanmod Kernel Only

**Requirements:**
- Must use **linux-xanmod** kernel (Magisk doesn't work with other kernels)
- Admin access needed

**Install via waydroid-script:**
```bash
sudo waydroid-extras
# Select: Magisk Delta
# Follow on-screen instructions
```

**Detailed Magisk guides:**
- https://github.com/casualsnek/waydroid_script#install-magisk
- https://github.com/nitanmarcel/waydroid-magisk

**Note:** Magisk Delta is the updated version supporting modern Android versions.

### Option 2: Shizuku (ADB Permissions) ✅ Recommended

**Why Shizuku?**
- Works with **all kernels** (not just xanmod)
- Covers ~99% of root-required use cases
- Apps get ADB permissions instead of full root
- Easier to set up and manage

**Install Shizuku:**
```bash
# From Play Store (requires GApps)
# or
waydroid app install shizuku.apk  # From F-Droid
```

**Grant ADB Permissions (every session):**
```bash
# After Waydroid UI has launched:
sudo waydroid shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
```

**Automate with Alias:**

Add to `~/.bashrc` or `~/.zshrc`:
```bash
alias waydroid-start='waydroid show-full-ui & sleep 10 && pkexec waydroid shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
```

**Adjust sleep duration** based on your system's Waydroid UI startup time:
- Modern processor (2020+): 10 seconds
- Mid-range processor (2017-2020): 20-30 seconds
- Older processor (pre-2017): 60 seconds

---

## 🎮 Gaming & Input Mapping

### Key Mapper Tools

Map keyboard and mouse to game controls for better gameplay.

#### Option 1: XtMapper

Download APK from [GitHub releases](https://github.com/Xtr126/XtMapper/releases):
```bash
waydroid app install XtMapper.apk
```

#### Option 2: Key Mapper & Floating Buttons

Available on [F-Droid](https://f-droid.org/) and Google Play Store:
```bash
waydroid app install keymapper.apk
```

**Tutorial:** [YouTube - How to use Key Mapper](https://www.youtube.com/results?search_query=key+mapper+tutorial)

**Real-world test:** Need for Speed: No Limits
- Keyboard mapped perfectly
- **Zero input lag**
- Smooth gameplay

---

## ⚙️ Waydroid-Settings: GPU Selection

Install the GTK GUI tool:
```bash
sudo pacman -S waydroid-settings
```

**Launch from application menu.**

**Features:**
- Select which GPU to use (for dual-GPU systems)
- Configure display settings
- Manage Waydroid container
- View system information

**Dual-GPU Setup:**
If you have Nvidia + Intel/AMD:
1. Open Waydroid-Settings
2. Select integrated GPU (Intel/AMD)
3. Waydroid will use integrated GPU exclusively

---

## 📂 File Sharing Between Linux and Android

### Quick Setup

Create shared folder accessible from both systems:

```bash
# Create Linux folder
mkdir -p ~/SharedWithAndroid

# Create mount target
sudo mkdir -p ~/.local/share/waydroid/data/media/0/SharedFolder

# Bind mount (temporary)
sudo mount --bind ~/SharedWithAndroid ~/.local/share/waydroid/data/media/0/SharedFolder

# Verify
mount | grep SharedFolder
```

**Access in Waydroid:** Files appear at `/sdcard/SharedFolder`

### Make File Sharing Permanent

Add to `/etc/fstab` (replace `YOUR_USERNAME`):

```
/home/YOUR_USERNAME/SharedWithAndroid /home/YOUR_USERNAME/.local/share/waydroid/data/media/0/SharedFolder none bind 0 0
```

Example for user `mak`:
```
/home/mak/SharedWithAndroid /home/mak/.local/share/waydroid/data/media/0/SharedFolder none bind 0 0
```

Reload fstab:
```bash
sudo mount -a
```

---

## 🌐 Network Configuration

### UFW Firewall Setup

If using UFW, configure for Waydroid networking:

```bash
# Allow DNS
sudo ufw allow 53

# Allow DHCP
sudo ufw allow 67

# Allow container forwarding
sudo ufw default allow FORWARD
```

> ⚠️ **Security Note:** `allow FORWARD` affects firewall forwarding policy. Be aware of security implications in your network setup.

### Network Troubleshooting

If Waydroid can't access the network:

```bash
# Check network status
waydroid status

# Test connectivity
waydroid shell ping 8.8.8.8

# Check DNS
waydroid shell cat /etc/resolv.conf
```

---

## 🛠️ Troubleshooting & Common Issues

### Binder Module Issues

**Error: Binder module not found**

```bash
# Check if loaded
lsmod | grep binder

# Load modules manually
sudo modprobe binder_linux
sudo modprobe ashmem_linux

# Check kernel config
zgrep ANDROID /proc/config.gz
```

**Solution:**
- Install kernel with built-in binder support, OR
- Install `binder_linux-dkms`

### PSI Warning: [gbinder] WARNING: Service manager /dev/binder has died

**Cause:** PSI (Pressure Stall Information) not enabled

**Fix for linux-xanmod:**

```bash
sudo nano /etc/default/grub

# Add psi=1 to GRUB_CMDLINE_LINUX_DEFAULT
# Example:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

**Fix for other kernels:**
- Switch to kernel with PSI support
- Or use linux-zen / linux-cachyos

### Kernel Switch Issues

**Error when switching kernels or changing binder configuration:**

```bash
# Complete reset
waydroid session stop
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container
sudo pkill -f waydroid

# Verify no processes remain
ps aux | grep waydroid

# Clean everything
rm -rf ~/.cache/waydroid
rm -rf ~/.local/share/waydroid
sudo rm -rf /run/waydroid
sudo rm -rf /usr/share/waydroid-extra

# Reinstall
sudo pacman -S waydroid

# Fresh start
sudo waydroid init -f
# or with GApps
sudo waydroid init -s GAPPS -f

# Re-enable services
sudo systemctl enable --now waydroid-container.service
waydroid session start
```

### Rotated Apps / Full-Screen Games Not Filling Display

**Issue:** App displays rotated or doesn't fill screen

**Solution:** Use windowed mode

```bash
# Press F11 while app is running
# F11 toggles between fullscreen and windowed mode
```

### Roblox and Games Rendering Issues

**Issue:** Roblox or other games display in rotated/incorrect orientation

**Fix:**

```bash
# Edit Waydroid GPU configuration
sudo nano /var/lib/waydroid/waydroid_base.prop

# Change GPU rendering backend
# FROM:
ro.hardware.gralloc=gbm

# TO:
ro.hardware.gralloc=minigbm_gbm_mesa

# Save and restart Waydroid
waydroid session stop
waydroid session start
```

**Source:** [Roblox on Waydroid Guide](https://gitlab.com/TestingPlant/roblox-on-waydroid-guide/) (comprehensive guide for many games)

### GPU Acceleration Issues (Nvidia, VMs)

**For Nvidia GPUs (non-Tegra):**

Use software rendering:
```bash
sudo nano /var/lib/waydroid/waydroid_base.prop

# Add or modify:
WAYDROID_USE_SWVENC=1
```

**For Virtual Machines:**

Software rendering is recommended. Use setting above.

### Download Speeds Very Slow During Init

**Issue:** `waydroid init` takes very long time

**Cause:** Geographic/ISP throttling of Waydroid repo

**Solution:** Use VPN

```bash
# Install VPN
sudo pacman -S riseup-vpn

# Connect to European server before running:
sudo waydroid init -s GAPPS
```

---

## 🏪 Open-Source App Stores

### F-Droid (FOSS Repository)

**Website:** https://f-droid.org/

**Install:**
1. Download F-Droid APK from https://f-droid.org/
2. Install: `waydroid app install F-Droid.apk`
3. Launch from Waydroid
4. Browse and install FOSS apps

### Aurora Store (Unofficial Play Store Client)

**Website:** https://auroraoss.com/

**Install:**
1. Download from GitHub releases
2. Install: `waydroid app install AuroraStore.apk`
3. Use without Google account (optional)

### microG Project (Open-source Google Services)

**Website:** https://microg.org/

Alternative to Google Play Services with privacy focus.

**Use when:**
- Can't access Google Play Store
- Want open-source alternative
- Privacy concerns

---

## 🚀 Auto-Start Launcher (No Password)

### Create Startup Script

Create `/usr/local/bin/start-waydroid.sh`:

```bash
#!/bin/bash
# Start Waydroid container & session
sudo systemctl start waydroid-container.service
waydroid session start
```

Make executable:
```bash
sudo chmod +x /usr/local/bin/start-waydroid.sh
```

### Create Desktop Entry

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

Make executable:
```bash
chmod +x ~/.local/share/applications/waydroid-start.desktop
update-desktop-database ~/.local/share/applications/
```

### Configure Passwordless sudo

Edit sudoers file:

```bash
EDITOR=nano sudo visudo
```

Add this line (replace `YOUR_USERNAME`):

```
YOUR_USERNAME ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service
```

Example for user `mak`:
```
mak ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service
```

**Now launch from application menu!**

---

## 📊 Useful Commands

### Status & Information
```bash
# Check Waydroid status
waydroid status

# Check Android version
waydroid shell getprop ro.build.version.release

# Check CPU architecture
waydroid shell getprop ro.product.cpu.abi
```

### App Management
```bash
# List installed apps
waydroid app list

# Install APK
waydroid app install /path/to/app.apk

# Launch specific app
waydroid app launch com.package.name

# Uninstall app
waydroid app remove com.package.name
```

### Container & Session
```bash
# Start container
sudo waydroid container start

# Stop container
sudo waydroid container stop

# Restart everything
sudo systemctl restart waydroid-container
waydroid session start

# Start session
waydroid session start

# Stop session
waydroid session stop
```

### Shell & Debugging
```bash
# Open Waydroid shell
sudo waydroid shell

# View logs
journalctl -u waydroid-container -f

# Check system properties
waydroid shell getprop

# Test network
waydroid shell ping 8.8.8.8

# Check disk usage
waydroid shell df -h
```

---

## 📚 Complete Resources

### Official Documentation
- **[Waydroid Official](https://waydro.id/)** - Main website
- **[Waydroid Docs](https://docs.waydro.id/)** - Complete documentation
- **[ArchWiki - Waydroid](https://wiki.archlinux.org/title/Waydroid)** - Arch-specific info
- **[GitHub Repository](https://github.com/waydroid/waydroid)** - Source code & issues

### Tools & Utilities
- **[Waydroid Helper](https://github.com/waydroid-helper/waydroid-helper)** - GUI configuration
- **[Waydroid Script](https://github.com/casualsnek/waydroid_script)** - GApps & ARM installation
- **[Waydroid Settings](https://github.com/axel358/waydroid-settings)** - GPU & settings control
- **[Roblox Guide](https://gitlab.com/TestingPlant/roblox-on-waydroid-guide/)** - Game-specific setup

### Related Projects
- **[Shizuku](https://github.com/RikkaApps/Shizuku)** - ADB permissions without root
- **[Magisk](https://github.com/topjohnwu/Magisk)** - Full root access (xanmod only)
- **[microG Project](https://microg.org/)** - Open-source Google services
- **[F-Droid](https://f-droid.org/)** - FOSS app repository
- **[Aurora Store](https://auroraoss.com/)** - Unofficial Play Store

---

## 💡 Key Takeaways

1. **Wayland is mandatory** - X11 will not work
2. **Binder modules are critical** - Install kernel with binder or use binder_linux-dkms
3. **GApps + ARM translation essential** - Need both for full app compatibility
4. **Choose ARM translation wisely:**
   - AMD GPU → libndk (better performance)
   - Intel CPU → libhoudini (better performance)
   - Android 13+ → MindTheGapps (better compatibility)
5. **Shizuku is recommended** - Works on all kernels, covers 99% of use cases
6. **PSI matters** - Enable psi=1 if using xanmod kernel or encounter binder errors
7. **Full reset solves most issues** - `sudo waydroid init -f` is your friend
8. **F11 for fullscreen issues** - Toggle windowed mode in problematic apps

---

## 🤝 Contributing & Feedback

Found an issue? Have a solution?

- Check [Waydroid issues](https://github.com/waydroid/waydroid/issues)
- Review [ArchWiki troubleshooting](https://wiki.archlinux.org/title/Waydroid#Troubleshooting)
- Test solutions thoroughly before reporting

**Share your experience:**
- What games work well?
- Which app translations performed best?
- Any unique hardware configurations?

---

**Last Updated:** January 2026

> **⚠️ Disclaimer:** This is a comprehensive community guide based on extensive research and testing. While efforts are made to be accurate, always review commands before running them. Your setup may vary based on hardware, kernel, and distribution version.
