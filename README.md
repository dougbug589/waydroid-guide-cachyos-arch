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

## � Quick Navigation

### 🚀 Installation Methods
Choose your preferred installation method:

**→ [Automated Script Installation](#-automated-installation-script) (Recommended)**  
One-click setup with automatic configuration and feature selection

**→ [Manual Step-by-Step Guide](#-comprehensive-prerequisites) (Advanced)**  
Complete manual installation with detailed explanations

### 🔧 Additional Resources
- [Prerequisites & Requirements](#-comprehensive-prerequisites)
- [Google Apps & ARM Translation](#install-gapps-and-arm-translation) (via [waydroid_script](https://github.com/casualsnek/waydroid_script))
- [Troubleshooting Guide](#troubleshooting)
- [Changelog](CHANGELOG.md) - Recent fixes and improvements

---

## 🚀 Automated Installation Script

**Quick and easy setup** - Handles everything automatically with interactive prompts.

### Features:
- ✅ Automatic kernel detection and validation
- ✅ Fresh install vs re-configuration detection
- ✅ Image preservation (saves bandwidth)
- ✅ Session mode selection (Full UI / Background / First launch)
- ✅ Integrated [waydroid_script](https://github.com/casualsnek/waydroid_script) for GApps & ARM
- ✅ Automatic service configuration
- ✅ Firewall setup (optional)
- ✅ File sharing setup (optional)

### Quick Start:

```bash
# Clone the repository
git clone https://github.com/dougbug589/waydroid-guide-cachyos-arch.git
cd waydroid-guide-cachyos-arch

# Run the installation script
chmod +x install-waydroid.sh
./install-waydroid.sh
```

The script will guide you through:
1. Kernel compatibility check
2. Waydroid installation
3. Image download or preservation
4. GApps & ARM translation (via [@casualsnek's waydroid_script](https://github.com/casualsnek/waydroid_script))
5. Optional features (file sharing, auto-start launcher)
6. Session mode selection

**Credits:** GApps and ARM translation powered by [@casualsnek's waydroid_script](https://github.com/casualsnek/waydroid_script)

---

## �📦 What is Waydroid?

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

#### Complete Kernel Analysis & Selection

| Kernel | Source | Binder | Performance | PSI | Notes |
|--------|--------|--------|-------------|-----|-------|
| **linux-zen** | Arch default | ✅ Built-in | Good | ✅ Yes | Optimized for desktop, good balance |
| **linux-cachyos** | CachyOS | ✅ Built-in | Excellent | ✅ Yes | Highly optimized for Cachyos, best default |
| **linux-cachyos-lts** | CachyOS | ✅ Built-in | Excellent | ✅ Yes | LTS stability with CachyOS optimization |
| **linux-xanmod** | chaotic-aur | ✅ Built-in | Best | ⚠️ Manual | Highest performance, requires PSI setup |
| **linux** (stock) | Arch default | ❌ No | Baseline | ✅ Yes | Needs binder_linux-dkms |
| **linux-hardened** | Arch repos | ❌ No | Good | ✅ Yes | Security-focused, needs binder_linux-dkms |
| **linux-lts** (stock) | Arch default | ❌ No | Baseline | ✅ Yes | LTS version, needs binder_linux-dkms |

#### Option A: Install Kernel with Built-in Binder (Recommended)

Choose **one** of these kernels (all include binder modules):

**1) linux-zen** (Arch Linux default - Best for most users)
```bash
# Check if already installed
uname -r | grep zen

# Install
sudo pacman -S linux-zen linux-zen-headers

# Set as boot default (grub will auto-detect next boot)
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

**Features:**
- ✅ Built-in binder support
- ✅ Desktop-optimized
- ✅ Stable and reliable
- ✅ Good performance
- ✅ No additional configuration needed

**2) linux-cachyos** or **linux-cachyos-lts** (CachyOS-optimized - Best performance)

```bash
# Check current kernel
uname -r

# List available cachyos kernels
sudo pacman -Ss linux-cachyos

# Install latest version
sudo pacman -S linux-cachyos linux-cachyos-headers

# Or install LTS version (longer support)
sudo pacman -S linux-cachyos-lts linux-cachyos-lts-headers

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

**Features:**
- ✅ Built-in binder support
- ✅ Highly optimized for performance
- ✅ CachyOS-specific tweaks
- ✅ Great for gaming
- ✅ No additional configuration
- ✅ LTS version available for stability

**3) linux-xanmod** (High performance, best for games - Requires extra config)

```bash
# Install from chaotic-aur
sudo pacman -S linux-xanmod linux-xanmod-headers

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# IMPORTANT: Configure PSI (see PSI Configuration section below)
sudo reboot
```

**Features:**
- ✅ Built-in binder support
- ✅ Highest performance
- ✅ Best for gaming/demanding workloads
- ⚠️ **REQUIRES PSI configuration** (critical!)
- ⚠️ More complex setup than others

**GUI Installation (Garuda users):**
```
Garuda Settings Manager → Hardware → Kernel
```

#### Important: PSI Configuration for linux-xanmod

If using **linux-xanmod**, you **MUST** enable PSI (Pressure Stall Information) or Waydroid will fail:

```bash
# Check current kernel
uname -r

# If it shows xanmod, proceed with PSI setup
# If not, you don't need this step

# Edit GRUB configuration
sudo nano /etc/default/grub

# FIND THIS LINE:
# GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# CHANGE IT TO THIS (add psi=1):
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"

# IMPORTANT: Make sure psi=1 is:
# - Inside the quotes
# - Before any # symbols
# - After "quiet splash"

# Example correct:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"

# Example WRONG (will not work):
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash" # psi=1

# Save and rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Verify PSI is enabled
cat /proc/cmdline | grep psi

# Reboot for changes to take effect
sudo reboot

# Verify after reboot
cat /proc/cmdline | grep psi  # Should show psi=1
```

**Why PSI matters:**
- Waydroid binder heavily uses PSI for communication
- Without PSI, you'll get: `[gbinder] WARNING: Service manager /dev/binder has died`
- PSI allows better pressure-based scheduling

#### Option B: Use Stock Kernel + binder_linux-dkms

If using Arch's stock kernel or another kernel without built-in binder:

```bash
# Check your current kernel
uname -r

# If it shows "arch", "hardened", or "lts", you need binder_linux-dkms

# Install DKMS version
sudo pacman -S binder_linux-dkms

# DKMS will automatically build for your kernel
# This may take a few minutes

# Verify installation
modprobe binder_linux
```

**DKMS Details:**
- Automatically builds binder modules for your kernel
- Rebuilds on kernel updates
- Works with any kernel
- Slightly slower than built-in (recompilation needed)

#### Verify Binder Module Support Before Installation

**ALWAYS check before installing Waydroid:**

```bash
# Test 1: Try loading binder module
sudo modprobe -a binder

# Test 2: Alternate name
sudo modprobe -a binder_linux

# If either command returns WITH NO OUTPUT, you're good!
# If it says "module not found", you need to:
# - Install kernel with binder support, OR
# - Install binder_linux-dkms

# Test 3: Check detailed kernel config
zgrep -i "android\|binder" /proc/config.gz

# Look for these in output:
# CONFIG_ANDROID=y         (kernel supports Android)
# CONFIG_ANDROID_BINDER_IPC=y  (kernel has binder)
# CONFIG_ANDROID_BINDER_IPC_ASYNC_MMAP_TLOOKUP=y

# Test 4: Check loaded modules
lsmod | grep binder

# If empty, modules aren't loaded yet (load them manually with modprobe)
```

**Verification Success:**
- `modprobe` returns with no error ✅
- `zgrep` shows `CONFIG_ANDROID=y` ✅
- Ready to install Waydroid ✅

#### Kernel-Specific Issues & Solutions

**Issue: "module binder not found" even after install**

```bash
# Cause: Module not built or kernel lacking support
# Solution 1: Check if binder is built-in (not modular)
grep BINDER /proc/config.gz | grep -i "^CONFIG_ANDROID_BINDER"

# If shows =m (modular), load it:
sudo modprobe binder_linux

# If shows =y (built-in), it should work. Reboot:
sudo reboot

# Solution 2: Install binder_linux-dkms
sudo pacman -S binder_linux-dkms

# Solution 3: Switch to kernel with built-in support
sudo pacman -S linux-zen linux-zen-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

**Issue: binder modules load but Waydroid still fails**

```bash
# Cause: Module loaded but binderfs not mounted
# Check if binderfs exists
ls /dev/binderfs

# If directory doesn't exist:
sudo mkdir -p /dev/binderfs

# Mount it
sudo mount -t binder binder /dev/binderfs

# Verify
mount | grep binder

# Make permanent (create systemd service as shown in Setup section)
```

**Issue: Switching kernels causes "permission denied" or binder errors**

```bash
# Cause: Old kernel modules incompatible with new kernel

# Complete recovery:
waydroid session stop
sudo systemctl stop waydroid-container
sudo systemctl disable waydroid-container
sudo pkill -f waydroid

# Clean cache and configs
rm -rf ~/.cache/waydroid
rm -rf ~/.local/share/waydroid
sudo rm -rf /run/waydroid

# Reinstall Waydroid
sudo pacman -S waydroid

# Reinitialize
sudo waydroid init -f
# or with GApps
sudo waydroid init -s GAPPS -f

# Re-enable and start
sudo systemctl enable --now waydroid-container
waydroid session start
```

**Issue: PSI warning appears but using xanmod**

```bash
# Error: [gbinder] WARNING: Service manager /dev/binder has died

# Verify PSI is configured
cat /proc/cmdline | grep psi

# If psi=1 NOT present:
# PSI configuration didn't take effect. Re-run:
sudo nano /etc/default/grub
# Add psi=1 to GRUB_CMDLINE_LINUX_DEFAULT

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot

# Verify after reboot
cat /proc/cmdline | grep psi  # Must show psi=1
```

**Issue: Kernel panic or won't boot after changing kernel**

```bash
# Use GRUB boot menu to select previous kernel:
# 1. Reboot
# 2. Hold Shift during boot (or press Esc)
# 3. Select "Advanced options for Arch"
# 4. Select previous working kernel
# 5. Boot

# Once booted:
# Uninstall problematic kernel
sudo pacman -Rns linux-xanmod  # replace with your kernel

# Go back to working kernel
sudo pacman -S linux-zen linux-zen-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Verify GRUB config has kernel entries
grep "^menuentry" /boot/grub/grub.cfg
```

#### Kernel Installation Verification Checklist

Before initializing Waydroid, verify:

```bash
# 1. Check you're on a supported kernel
echo "Current kernel: $(uname -r)"

# 2. Verify binder support
sudo modprobe binder_linux 2>/dev/null && echo "✅ Binder module available" || echo "❌ Binder module NOT available"

# 3. Check Android kernel config
zgrep CONFIG_ANDROID /proc/config.gz | head -5

# 4. If using xanmod, verify PSI
if uname -r | grep -q xanmod; then
    cat /proc/cmdline | grep psi && echo "✅ PSI enabled" || echo "❌ PSI NOT enabled - CRITICAL!"
fi

# 5. Verify binderfs mount point
ls /dev/binderfs && echo "✅ binderfs exists" || echo "⚠️ binderfs not mounted yet (will be created)"

# If all checks pass or show warnings, proceed with Waydroid setup
```

#### Hardware-Specific Kernel Recommendations

**AMD CPU with AMD GPU:**
```bash
# Best: linux-cachyos (optimized for AMD)
sudo pacman -S linux-cachyos linux-cachyos-headers
```

**Intel CPU with Intel iGPU:**
```bash
# Best: linux-zen (good balance, no extra config)
sudo pacman -S linux-zen linux-zen-headers
```

**Gaming-focused (any CPU):**
```bash
# Best: linux-xanmod (highest performance, requires PSI setup)
sudo pacman -S linux-xanmod linux-xanmod-headers
# Don't forget to configure PSI!
```

**CachyOS system:**
```bash
# Best: linux-cachyos (native support)
sudo pacman -S linux-cachyos linux-cachyos-headers
```

**Stability/LTS priority:**
```bash
# Best: linux-cachyos-lts or linux-zen
sudo pacman -S linux-cachyos-lts linux-cachyos-lts-headers
```

**Nvidia GPU (software rendering):**
```bash
# Any kernel works, no special config
# Use: linux-zen (simplest)
sudo pacman -S linux-zen linux-zen-headers
# Or: linux-cachyos (better performance)
```

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

### Kernel & Binder Issues (Deep Dive)

#### Understanding Kernel & Binder Architecture

**How Waydroid uses binder:**
1. Android container needs binder IPC (inter-process communication)
2. Kernel provides binder module
3. Module creates `/dev/binder` device
4. Waydroid mounts binderfs at `/dev/binderfs`
5. Android processes communicate through binder

**If any step fails, Waydroid won't work.**

#### Complete Binder Module Troubleshooting

**Step 1: Check if kernel has binder support**

```bash
# Method 1: Try loading module
sudo modprobe binder_linux 2>&1

# Expected output (if available):
# (nothing - module loads silently)

# Expected error (if not available):
# modprobe: FATAL: Module binder_linux not found in directory /lib/modules/6.x.x-xxx/kernel

# Method 2: Check kernel config in detail
zgrep -i "ANDROID\|BINDER" /proc/config.gz

# You should see:
# CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC=y
# CONFIG_ANDROID_BINDER_IPC_ASYNC_MMAP_TLOOKUP=y
```

**Step 2: Load modules and mount binderfs**

```bash
# Load modules
sudo modprobe -a binder_linux ashmem_linux

# Verify modules loaded
lsmod | grep -E "binder|ashmem"

# Example output:
# ashmem_linux           16384  0
# binder_linux           110592  0

# Mount binderfs
sudo mkdir -p /dev/binderfs
sudo mount -t binder binder /dev/binderfs

# Verify mount
mount | grep binder
# Expected: binder on /dev/binderfs type binder (rw,relatime)

# Check device created
ls -la /dev/binderfs
```

**Step 3: Make binderfs mount permanent**

If binder works but isn't persisting across reboots:

```bash
# Create systemd service
sudo nano /etc/systemd/system/binderfs.service
```

Add this content:
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
sudo systemctl daemon-reload
sudo systemctl enable binderfs.service
sudo systemctl start binderfs.service

# Verify
mount | grep binder
```

#### Binder Error: "Module not found" Even After Install

**Scenario 1: Kernel has binder built-in but as modular**

```bash
# Check if binder is modular
grep BINDER /proc/config.gz | grep "=m"

# If yes, load the module:
sudo modprobe binder_linux

# Verify loaded:
lsmod | grep binder
```

**Scenario 2: binder_linux-dkms installed but not rebuilt**

```bash
# Force rebuild for current kernel
sudo dkms build binder_linux

# Install
sudo dkms install binder_linux

# Verify
modprobe binder_linux
```

**Scenario 3: Wrong kernel version**

```bash
# Check running kernel
uname -r
# Example: 6.12.1-arch1-1

# Check what binder_linux was built for
modinfo binder_linux 2>/dev/null || echo "Module not found"

# Solution: Install kernel with built-in binder
sudo pacman -S linux-zen linux-zen-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

#### PSI Configuration Issues (xanmod kernel)

**Error: [gbinder] WARNING: Service manager /dev/binder has died**

Cause: PSI not enabled on xanmod kernel

**Fix:**

```bash
# Verify PSI configured in boot params
cat /proc/cmdline | grep psi

# Should show: psi=1

# If NOT present:
sudo nano /etc/default/grub

# Current (wrong):
# GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# Change to:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"

# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Reboot and verify
sudo reboot
cat /proc/cmdline | grep psi  # Must show psi=1
```

**Why PSI matters on xanmod:**
- Xanmod is heavily optimized for pressure-based scheduling
- Binder relies on PSI for interprocess communication
- Without PSI, communication fails → "binder has died" error

#### Kernel Switch Recovery

**Scenario: You switched kernels and Waydroid now crashes**

```bash
# Stop everything
waydroid session stop
sudo systemctl stop waydroid-container waydroid-container.socket
sudo pkill -f waydroid

# Verify stopped
ps aux | grep waydroid | grep -v grep  # Should be empty

# Check new kernel has binder support
sudo modprobe binder_linux && echo "✅ Binder available" || echo "❌ Binder NOT available"

# If binder not available:
# - Install kernel with binder support
# - OR install binder_linux-dkms

# Clean old kernel modules/configs
rm -rf ~/.cache/waydroid
rm -rf ~/.local/share/waydroid
sudo rm -rf /run/waydroid

# Reinstall Waydroid clean
sudo pacman -Sy waydroid

# Reinitialize completely
sudo waydroid init -f
# or with GApps
sudo waydroid init -s GAPPS -f

# Test binder first
sudo modprobe binder_linux

# Re-enable services
sudo systemctl daemon-reload
sudo systemctl enable --now waydroid-container.service
waydroid session start

# Verify status
waydroid status
```

#### Kernel Boot Issues After PSI Configuration

**Problem: System won't boot after adding psi=1 to GRUB**

```bash
# At boot menu, select previous kernel or recovery mode
# Or edit GRUB entry to remove psi=1

# Once booted, fix GRUB:
sudo nano /etc/default/grub

# Remove psi=1 if it was incorrectly formatted
# Correct format:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash psi=1"

# Incorrect format (will fail):
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash" psi=1  # psi=1 outside quotes!

# Rebuild
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

#### Hardware-Specific Kernel Issues

**AMD CPUs with binder_linux-dkms:**
```bash
# Sometimes needs to rebuild modules
sudo dkms autoinstall

# Verify
sudo modprobe binder_linux
```

**Intel CPUs with custom kernels:**
```bash
# Check if kernel config has Android support
zgrep CONFIG_ANDROID /proc/config.gz

# If empty, you need kernel with Android support
```

**Virtual Machines:**
```bash
# VMs typically don't have binder support built-in
# Install binder_linux-dkms
sudo pacman -S binder_linux-dkms

# Rebuild for VM kernel
sudo dkms install binder_linux

# Test
sudo modprobe binder_linux
```

#### Kernel Update Broke Binder

**After `sudo pacman -Syu`, Waydroid fails**

```bash
# Check kernel version changed
uname -r

# If kernel updated, modules may need rebuild:
sudo dkms autoinstall

# Or manually rebuild binder
sudo dkms build binder_linux
sudo dkms install binder_linux

# Test
sudo modprobe binder_linux

# Restart Waydroid
sudo systemctl restart waydroid-container
waydroid session start
```

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
- **[Waydroid Script](https://github.com/casualsnek/waydroid_script)** by [@casualsnek](https://github.com/casualsnek) - GApps & ARM installation
- **[Waydroid Settings](https://github.com/axel358/waydroid-settings)** - GPU & settings control
- **[Roblox Guide](https://gitlab.com/TestingPlant/roblox-on-waydroid-guide/)** - Game-specific setup

### Related Projects
- **[Shizuku](https://github.com/RikkaApps/Shizuku)** - ADB permissions without root
- **[Magisk](https://github.com/topjohnwu/Magisk)** - Full root access (xanmod only)
- **[microG Project](https://microg.org/)** - Open-source Google services
- **[F-Droid](https://f-droid.org/)** - FOSS app repository
- **[Aurora Store](https://auroraoss.com/)** - Unofficial Play Store

---

## 🙏 Credits & Attribution

### Core Projects
- **[Waydroid](https://github.com/waydroid/waydroid)** - The amazing Android container project
- **[@casualsnek](https://github.com/casualsnek)** - Creator of [waydroid_script](https://github.com/casualsnek/waydroid_script) for GApps/ARM installation
- **Original Guide** - [dougbug589](https://github.com/dougbug589) for the initial waydroid-guide-cachyos-arch

### Contributors
- Script automation and improvements by the community
- Testing and troubleshooting by Arch/CachyOS users
- Documentation contributions from various sources

### Special Thanks
This guide integrates and builds upon:
- Official Waydroid documentation
- Arch Linux Wiki community knowledge
- @casualsnek's waydroid_script for automated GApps/ARM setup
- Community troubleshooting and solutions

**See [CHANGELOG.md](CHANGELOG.md) for recent improvements and fixes**

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
