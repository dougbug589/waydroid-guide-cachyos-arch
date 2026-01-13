#!/bin/bash
#
# Waydroid Installer for Arch-based Linux Distributions
# Comprehensive automated setup for Waydroid with optional features
#
# Supports: Arch Linux, Garuda, CachyOS, EndeavourOS, and other Arch-based distros
# Based on: https://github.com/dougbug589/waydroid-guide-cachyos-arch
#
# Usage: ./install-waydroid.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${GREEN}==>${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script must NOT be run as root (don't use sudo)"
   exit 1
fi

# Get username for later use
SCRIPT_USER="${SUDO_USER:-$USER}"
SCRIPT_HOME=$(eval echo ~$SCRIPT_USER)

# Check if running Wayland
print_step "Checking prerequisites..."
if [[ -z "$WAYLAND_DISPLAY" ]] && [[ -z "$WAYLAND_SOCKET" ]]; then
    print_warning "Not running in a Wayland session. Waydroid requires Wayland!"
    echo "Current session type: $XDG_SESSION_TYPE"
    read -p "Continue anyway? (y/N): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled. Please switch to a Wayland session."
        exit 1
    fi
fi

# Check if Arch-based
if [[ ! -f /etc/pacman.conf ]]; then
    print_error "This script is for Arch-based distributions only"
    exit 1
fi

print_success "Prerequisites check passed"

# Check kernel compatibility
print_step "Checking kernel compatibility..."
KERNEL_NAME=$(uname -r)
print_info "Current kernel: $KERNEL_NAME"

# List of supported kernels (case-insensitive check)
SUPPORTED_KERNELS=("zen" "cachyos" "xanmod" "lts" "hardened" "clear")
KERNEL_SUPPORTED=false

# Check if kernel name contains any of the supported kernel names
for supported in "${SUPPORTED_KERNELS[@]}"; do
    if [[ "$KERNEL_NAME" =~ $supported ]]; then
        KERNEL_SUPPORTED=true
        print_success "Kernel '$KERNEL_NAME' is supported (matched: $supported)"
        break
    fi
done

# Additional check for binder support
if [[ "$KERNEL_SUPPORTED" == false ]]; then
    if zgrep -q "CONFIG_ANDROID=y" /proc/config.gz 2>/dev/null || modprobe -n binder_linux &>/dev/null; then
        print_warning "Kernel name not recognized, but binder support detected"
        KERNEL_SUPPORTED=true
    fi
fi

# Exit if kernel is not supported
if [[ "$KERNEL_SUPPORTED" == false ]]; then
    print_error "Unsupported kernel: $KERNEL_NAME"
    echo ""
    echo "Waydroid requires a kernel with Android/binder support."
    echo "Supported kernels:"
    echo "  - linux-zen (recommended for most users)"
    echo "  - linux-cachyos (CachyOS optimized)"
    echo "  - linux-xanmod (high performance)"
    echo "  - linux-lts (with binder_linux-dkms)"
    echo "  - linux-hardened"
    echo "  - linux-clear"
    echo ""
    echo "You can install a supported kernel with:"
    echo "  sudo pacman -S linux-zen linux-zen-headers"
    echo ""
    echo "Or install binder module for your current kernel:"
    echo "  sudo pacman -S binder_linux-dkms"
    echo ""
    print_error "Installation cannot proceed with unsupported kernel"
    exit 1
fi

# Install Waydroid
print_step "Installing Waydroid..."
if pacman -Q waydroid &> /dev/null; then
    print_info "Waydroid is already installed"
else
    sudo pacman -S --noconfirm waydroid
    print_success "Waydroid installed"
fi

# Mount binderfs
print_step "Setting up binderfs..."
if mount | grep -q binderfs; then
    print_info "binderfs already mounted"
else
    sudo mkdir -p /dev/binderfs
    sudo mount -t binder binder /dev/binderfs
    print_success "binderfs mounted"
fi

# Create systemd service for binderfs
print_info "Creating systemd service for persistent binderfs..."
sudo tee /etc/systemd/system/binderfs.service > /dev/null <<'EOF'
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
EOF

sudo systemctl enable binderfs.service
print_success "binderfs systemd service created and enabled"

# Initialize Waydroid
print_step "Initializing Waydroid..."

# Check if images already exist
if [[ -f /var/lib/waydroid/images/system.img ]] && [[ -f /var/lib/waydroid/images/vendor.img ]]; then
    print_success "Waydroid images found!"
    print_info "System image: $(du -h /var/lib/waydroid/images/system.img | cut -f1)"
    print_info "Vendor image: $(du -h /var/lib/waydroid/images/vendor.img | cut -f1)"
    echo ""
    read -p "Keep existing images? (Y/n): " keep_images
    
    if [[ "$keep_images" =~ ^[Nn]$ ]]; then
        print_warning "Will re-download images..."
        read -p "Install Google Play Store (GApps)? (y/N): " install_gapps
        if [[ "$install_gapps" =~ ^[Yy]$ ]]; then
            sudo waydroid init -s GAPPS -f
            print_success "Waydroid re-initialized with GApps"
        else
            sudo waydroid init -f
            print_success "Waydroid re-initialized (no GApps)"
        fi
    else
        print_info "Keeping existing Waydroid images"
        # Still need to ensure config exists
        if [[ ! -f /var/lib/waydroid/waydroid.cfg ]]; then
            print_warning "Config missing, running init without downloading images..."
            sudo waydroid init || print_warning "Init failed but images are present"
        fi
    fi
elif [[ -d /var/lib/waydroid ]]; then
    print_warning "Waydroid directory exists but images incomplete"
    read -p "Re-initialize? (Y/n): " reinit
    read -p "Install Google Play Store (GApps)? (y/N): " install_gapps
    
    if [[ ! "$reinit" =~ ^[Nn]$ ]]; then
        if [[ "$install_gapps" =~ ^[Yy]$ ]]; then
            sudo waydroid init -s GAPPS -f
            print_success "Waydroid initialized with GApps"
        else
            sudo waydroid init -f
            print_success "Waydroid initialized (no GApps)"
        fi
    else
        print_info "Skipping initialization"
    fi
else
    read -p "Install Google Play Store (GApps)? (y/N): " install_gapps
    if [[ "$install_gapps" =~ ^[Yy]$ ]]; then
        sudo waydroid init -s GAPPS
        print_success "Waydroid initialized with GApps"
    else
        sudo waydroid init
        print_success "Waydroid initialized (no GApps)"
    fi
fi

# Enable and start services
print_step "Enabling and starting Waydroid services..."
sudo systemctl daemon-reload
sudo systemctl enable --now waydroid-container.service

# Only enable socket if it exists
if systemctl list-unit-files waydroid-container.socket &>/dev/null; then
    sudo systemctl enable --now waydroid-container.socket
    print_info "waydroid-container.socket enabled"
else
    print_info "waydroid-container.socket not found (not needed for all setups)"
fi

# Mask freeze timer if it exists
if systemctl list-unit-files waydroid-container-freeze.timer &>/dev/null; then
    sudo systemctl mask waydroid-container-freeze.timer
fi

print_success "Waydroid services enabled and started"

# Configure UFW (if installed)
if command -v ufw &> /dev/null; then
    print_step "Configuring firewall (UFW)..."
    read -p "Configure UFW for Waydroid? (y/N): " config_ufw
    if [[ "$config_ufw" =~ ^[Yy]$ ]]; then
        sudo ufw allow 53
        sudo ufw allow 67
        print_warning "Setting UFW to allow FORWARD (affects firewall security)"
        sudo ufw default allow FORWARD
        print_success "UFW configured"
    fi
fi

# Install waydroid_script for GApps and ARM support
print_step "Optional: Install Google Apps and ARM support"

# Check if waydroid-script-git is already installed
if pacman -Q waydroid-script-git &> /dev/null; then
    print_success "waydroid-script-git is already installed"
    read -p "Run waydroid-extras to install GApps/ARM? (y/N): " run_extras
    if [[ "$run_extras" =~ ^[Yy]$ ]]; then
        sudo waydroid-extras
    fi
else
    print_info "waydroid-script-git not found"
    read -p "Install waydroid-script for GApps/ARM translation? (y/N): " install_script
    if [[ "$install_script" =~ ^[Yy]$ ]]; then
        # Check if waydroid-helper is available (GUI alternative)
        if pacman -Q waydroid-helper &> /dev/null; then
            print_info "waydroid-helper (GUI) is also available: sudo pacman -S waydroid-helper"
        fi
        
        print_info "Installing waydroid-script-git..."
        if sudo pacman -S --noconfirm waydroid-script-git; then
            print_success "waydroid-script-git installed"
            read -p "Run waydroid-extras now? (y/N): " run_extras
            if [[ "$run_extras" =~ ^[Yy]$ ]]; then
                sudo waydroid-extras
            fi
        else
            print_error "Failed to install waydroid-script-git"
            print_info "You can try manually: sudo pacman -S waydroid-script-git"
        fi
    fi
fi

# Setup file sharing
print_step "Optional: Setup file sharing with Android"
read -p "Setup file sharing folder? (y/N): " setup_share
if [[ "$setup_share" =~ ^[Yy]$ ]]; then
    SHARE_PATH="$SCRIPT_HOME/SharedWithAndroid"
    MOUNT_TARGET="$SCRIPT_HOME/.local/share/waydroid/data/media/0/SharedFolder"
    
    mkdir -p "$SHARE_PATH"
    sudo mkdir -p "$MOUNT_TARGET"
    
    # Mount it
    sudo mount --bind "$SHARE_PATH" "$MOUNT_TARGET" 2>/dev/null || print_warning "Could not mount immediately"
    
    # Add to fstab for persistence
    MOUNT_LINE="$SHARE_PATH $MOUNT_TARGET none bind 0 0"
    if ! grep -q "$MOUNT_TARGET" /etc/fstab; then
        print_info "Adding bind mount to /etc/fstab..."
        echo "$MOUNT_LINE" | sudo tee -a /etc/fstab > /dev/null
        sudo mount -a
        print_success "File sharing configured (persistent)"
        print_info "Access shared files at: /sdcard/SharedFolder in Waydroid"
    else
        print_info "Bind mount already in /etc/fstab"
    fi
fi

# Setup auto-start without password
print_step "Optional: Setup auto-start launcher"
read -p "Create auto-start launcher (no password required)? (y/N): " setup_autostart
if [[ "$setup_autostart" =~ ^[Yy]$ ]]; then
    # Create startup script
    print_info "Creating startup script..."
    sudo tee /usr/local/bin/start-waydroid.sh > /dev/null <<'EOF'
#!/bin/bash
# Start Waydroid container & session
sudo systemctl start waydroid-container.service
waydroid session start
EOF
    sudo chmod +x /usr/local/bin/start-waydroid.sh
    
    # Create desktop entry
    print_info "Creating desktop entry..."
    mkdir -p "$SCRIPT_HOME/.local/share/applications"
    cat > "$SCRIPT_HOME/.local/share/applications/waydroid-start.desktop" <<'EOF'
[Desktop Entry]
Name=Start Waydroid
Comment=Start Waydroid container and session
Exec=/usr/local/bin/start-waydroid.sh
Icon=waydroid
Type=Application
Terminal=false
StartupNotify=true
Categories=Utility;
EOF
    chmod +x "$SCRIPT_HOME/.local/share/applications/waydroid-start.desktop"
    update-desktop-database "$SCRIPT_HOME/.local/share/applications/" 2>/dev/null || true
    
    # Configure sudoers
    print_info "Configuring sudoers for passwordless systemctl..."
    SUDOERS_LINE="$SCRIPT_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service"
    SUDOERS_FILE="/etc/sudoers.d/waydroid-$SCRIPT_USER"
    
    echo "$SUDOERS_LINE" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 0440 "$SUDOERS_FILE"
    
    print_success "Auto-start launcher created"
    print_info "You can now start Waydroid from your application menu!"
fi

# Start Waydroid
print_step "Installation complete!"
echo ""
print_success "Waydroid has been installed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Start Waydroid: waydroid show-full-ui"
echo "  2. Or use the 'Start Waydroid' launcher from your application menu"
echo "  3. Install apps: waydroid app install /path/to/app.apk"
echo "  4. List installed apps: waydroid app list"
echo "  5. Check status: waydroid status"
echo ""
print_info "Useful commands:"
echo "  - View logs: journalctl -u waydroid-container -f"
echo "  - Check Android version: waydroid shell getprop ro.build.version.release"
echo "  - Open shell: sudo waydroid shell"
echo ""
print_info "For more information, see: https://docs.waydro.id/"
echo ""

read -p "Start Waydroid session now? (y/N): " start_now
if [[ "$start_now" =~ ^[Yy]$ ]]; then
    print_info "Starting Waydroid session..."
    print_warning "Waiting for container to start (this may take a minute)..."
    waydroid session start &
    SESSION_PID=$!
    
    # Wait for session to be ready
    for i in {1..30}; do
        if waydroid status 2>/dev/null | grep -q "RUNNING"; then
            print_success "Waydroid session is ready!"
            break
        fi
        sleep 2
    done
    
    print_info "Launching Waydroid UI..."
    waydroid show-full-ui &
    wait $SESSION_PID 2>/dev/null || true
fi

print_success "Done! Enjoy Waydroid!"
