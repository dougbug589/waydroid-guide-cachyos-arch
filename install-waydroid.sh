#!/bin/bash
#
# Waydroid Installer for Arch-based Linux Distributions
# Comprehensive automated setup for Waydroid with optional features
#
# Supports: Arch Linux, Garuda, CachyOS, EndeavourOS, and other Arch-based distros
# Based on: https://github.com/dougbug589/waydroid-guide-cachyos-arch
#
# Credits:
#   - GApps & ARM translation: @casualsnek (https://github.com/casualsnek/waydroid_script)
#   - Waydroid Project: https://waydro.id/
#   - Community contributions and testing
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

# Detect if this is a fresh install or re-configuration
print_step "Detecting system state..."
IS_FRESH_INSTALL=true

if pacman -Q waydroid &> /dev/null; then
    print_info "Waydroid package detected"
    IS_FRESH_INSTALL=false
fi

if [[ -d /var/lib/waydroid ]] && [[ -f /var/lib/waydroid/images/system.img ]]; then
    print_info "Waydroid data and images detected"
    IS_FRESH_INSTALL=false
fi

if systemctl is-enabled waydroid-container.service &>/dev/null; then
    print_info "Waydroid services are enabled"
    IS_FRESH_INSTALL=false
fi

if [[ "$IS_FRESH_INSTALL" == true ]]; then
    print_success "Fresh installation detected - Full setup will run"
else
    print_warning "Existing Waydroid installation detected - Re-configuration mode"
    echo ""
    echo "Options:"
    echo "  1. Continue to check/update configuration"
    echo "  2. Exit (nothing will be changed)"
    echo ""
    read -p "Choose (1/2): " reconfig_choice
    if [[ "$reconfig_choice" != "1" ]]; then
        print_info "Exiting without changes"
        exit 0
    fi
    print_info "Re-configuration mode: Will check and optionally update settings"
fi

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

# Check if waydroid-extras command is available (from any source)
WAYDROID_EXTRAS_CMD=""
WAYDROID_SCRIPT_DIR="$SCRIPT_HOME/.local/share/waydroid_script"

# Check if cloned directory exists first (highest priority)
if [[ -d "$WAYDROID_SCRIPT_DIR" ]]; then
    print_success "waydroid_script found at: $WAYDROID_SCRIPT_DIR"
    read -p "Update and run waydroid_extras? (y/N): " update_script
    if [[ "$update_script" =~ ^[Yy]$ ]]; then
        print_info "Updating waydroid_script from GitHub..."
        cd "$WAYDROID_SCRIPT_DIR"
        git pull
        
        # Setup venv if not exists
        if [[ ! -d "venv" ]]; then
            print_info "Creating virtual environment..."
            python3 -m venv venv
            venv/bin/pip install -r requirements.txt
        fi
        
        print_success "Updated"
        sudo venv/bin/python3 main.py
    fi
# Check if installed via package
elif pacman -Q waydroid-script-git &> /dev/null; then
    print_success "waydroid-script-git is already installed (from package)"
    read -p "Run waydroid-extras to install GApps/ARM? (y/N): " run_extras
    if [[ "$run_extras" =~ ^[Yy]$ ]]; then
        sudo waydroid-extras
    fi
# Check if command exists in PATH
elif command -v waydroid-extras &> /dev/null || command -v waydroid_extras &> /dev/null; then
    if command -v waydroid-extras &> /dev/null; then
        WAYDROID_EXTRAS_CMD="waydroid-extras"
    else
        WAYDROID_EXTRAS_CMD="waydroid_extras"
    fi
    EXTRAS_PATH=$(which $WAYDROID_EXTRAS_CMD)
    print_success "waydroid-extras found at: $EXTRAS_PATH (manual installation)"
    read -p "Run waydroid-extras to install GApps/ARM? (y/N): " run_extras
    if [[ "$run_extras" =~ ^[Yy]$ ]]; then
        sudo $WAYDROID_EXTRAS_CMD
    fi
else
    # Not found - install from GitHub following author's instructions
    print_info "waydroid_script not found in system"
    read -p "Install waydroid_script from GitHub? (Y/n): " install_script
    if [[ ! "$install_script" =~ ^[Nn]$ ]]; then
        print_info "Installing waydroid_script from GitHub..."
        print_info "Repository: https://github.com/casualsnek/waydroid_script"

        # Install system dependencies (git, python, lzip)
        print_info "Installing system dependencies..."
        sudo pacman -S --needed --noconfirm python git lzip
        
        # Clone repository
        mkdir -p "$(dirname "$WAYDROID_SCRIPT_DIR")"
        if git clone https://github.com/casualsnek/waydroid_script.git "$WAYDROID_SCRIPT_DIR"; then
            print_success "waydroid_script cloned to: $WAYDROID_SCRIPT_DIR"
            
            # Follow author's exact installation steps
            cd "$WAYDROID_SCRIPT_DIR"
            print_info "Creating Python virtual environment..."
            python3 -m venv venv
            
            print_info "Installing Python dependencies..."
            venv/bin/pip install -r requirements.txt
            
            print_success "Installation complete!"
            echo ""
            
            read -p "Run waydroid_script now? (y/N): " run_script
            if [[ "$run_script" =~ ^[Yy]$ ]]; then
                print_info "Launching waydroid_script..."
                sudo venv/bin/python3 main.py
            else
                print_info "To run later, use:"
                echo "  cd $WAYDROID_SCRIPT_DIR"
                echo "  sudo venv/bin/python3 main.py"
            fi
        else
            print_error "Failed to clone waydroid_script from GitHub"
            print_info "You can manually clone: git clone https://github.com/casualsnek/waydroid_script.git"
        fi
    fi
fi

# Setup file sharing (symlink method)
print_step "Optional: Setup file sharing with Android (Symlink Method)"
read -p "Setup file sharing with symlinks? (y/N): " setup_share
if [[ "$setup_share" =~ ^[Yy]$ ]]; then
    print_info "Using symlink method for instant file transfer"
    
    # Check if Waydroid data directory exists
    WAYDROID_DATA="$SCRIPT_HOME/.local/share/waydroid/data/media/0"
    if [[ ! -d "$WAYDROID_DATA" ]]; then
        print_warning "Waydroid not initialized yet. Please run 'waydroid session start' first."
        print_info "Skipping file sharing setup for now. You can set it up manually later."
    else
        # Check if user is already in waydroid group
        if groups | grep -q "waydroid"; then
            print_info "Already in waydroid group (1023)"
        else
            # Add user to waydroid group (1023)
            print_info "Adding $SCRIPT_USER to waydroid group (1023)..."
            
            # Check if group already exists
            if grep -q "^waydroid:x:1023:" /etc/group; then
                # Group exists, just add user to it
                sudo usermod -aG waydroid "$SCRIPT_USER"
                print_success "Added to existing waydroid group"
            else
                # Create group and add user
                echo "waydroid:x:1023:$SCRIPT_USER" | sudo tee -a /etc/group > /dev/null
                print_success "Created waydroid group and added user"
            fi
            
            print_warning "Group membership requires re-login or reboot to take effect"
        fi
        
        # Create a single shared folder
        SHARED_FOLDER="Waydroid"
        SYMLINK_PATH="$SCRIPT_HOME/$SHARED_FOLDER"
        WAYDROID_SHARED="$WAYDROID_DATA/$SHARED_FOLDER"
        
        print_info "Creating shared folder in Waydroid..."
        
        # Create the folder in Waydroid's internal storage
        if [[ ! -d "$WAYDROID_SHARED" ]]; then
            mkdir -p "$WAYDROID_SHARED"
            print_success "Created folder in Waydroid: $SHARED_FOLDER"
        else
            print_info "Folder already exists in Waydroid: $SHARED_FOLDER"
        fi
        
        # Create symlink from home directory to Waydroid folder
        if [[ ! -e "$SYMLINK_PATH" ]]; then
            ln -s "$WAYDROID_SHARED" "$SYMLINK_PATH"
            print_success "Created symlink: ~/$SHARED_FOLDER"
        else
            if [[ -L "$SYMLINK_PATH" ]]; then
                print_info "Symlink already exists: ~/$SHARED_FOLDER"
            else
                print_error "~/$SHARED_FOLDER exists but is not a symlink. Please remove it first."
            fi
        fi
        
        echo ""
        print_success "✅ File sharing symlink created!"
        echo ""
        print_info "Access shared files from:"
        echo "  📁 Linux:    ~/$SHARED_FOLDER"
        echo "  📱 Android:  Internal storage/$SHARED_FOLDER"
        echo ""
        print_info "How to use:"
        echo "  1. Copy files to ~/$SHARED_FOLDER"
        echo "  2. Files appear instantly in Android - no restart needed!"
        echo "  3. Changes work both ways (Linux ↔ Android)"
        echo ""
        
        if ! groups | grep -q "waydroid"; then
            print_warning "IMPORTANT: You must re-login or reboot for group permissions to take effect!"
            read -p "Reboot now to apply group permissions? (y/N): " do_reboot
            if [[ "$do_reboot" =~ ^[Yy]$ ]]; then
                print_info "Rebooting system..."
                sudo reboot
            else
                print_info "Remember to reboot later: sudo reboot"
            fi
        fi
    fi
fi

# Installation complete
print_step "Installation complete!"
echo ""
print_success "Waydroid has been installed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Start Waydroid: waydroid show-full-ui"
echo "  2. Install apps: waydroid app install /path/to/app.apk"
echo "  3. List installed apps: waydroid app list"
echo "  4. Check status: waydroid status"
echo ""
print_info "Useful commands:"
echo "  - View logs: journalctl -u waydroid-container -f"
echo "  - Stop session: waydroid session stop"
echo "  - Unfreeze (if frozen): sudo waydroid container unfreeze"
echo "  - Check Android version: waydroid shell getprop ro.build.version.release"
echo "  - Open shell: sudo waydroid shell"
echo ""
print_info "For more information, see: https://docs.waydro.id/"
echo ""

read -p "Start Waydroid now? (y/N): " start_now
if [[ "$start_now" =~ ^[Yy]$ ]]; then
    # Check if container is frozen and unfreeze if needed
    if waydroid status 2>/dev/null | grep -q "FROZEN"; then
        print_warning "Container is frozen, unfreezing..."
        sudo waydroid container unfreeze
        sleep 2
    fi
    
    print_info "Starting Waydroid..."
    waydroid show-full-ui &
    print_success "Waydroid started!"
    print_info "Android interface should appear shortly"
fi

print_success "Done! Enjoy Waydroid!"
echo "  View logs:                journalctl -u waydroid-container -f"
echo "  Open shell:               sudo waydroid shell"
echo "  Stop container:           sudo waydroid container stop"
echo "  Restart container:        sudo waydroid container restart"

