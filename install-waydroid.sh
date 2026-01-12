#!/bin/bash
#
# Waydroid Installer for CachyOS/Arch Linux
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

# Check if running Wayland
print_step "Checking prerequisites..."
if [[ -z "$WAYLAND_DISPLAY" ]]; then
    print_warning "Not running Wayland session. Waydroid requires Wayland!"
    read -p "Continue anyway? (y/N): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Arch-based
if [[ ! -f /etc/pacman.conf ]]; then
    print_error "This script is for Arch-based distributions only"
    exit 1
fi

print_success "Prerequisites check passed"

# Install Waydroid
print_step "Installing Waydroid..."
if pacman -Q waydroid &> /dev/null; then
    print_info "Waydroid is already installed"
else
    sudo pacman -S --noconfirm waydroid
    print_success "Waydroid installed"
fi

# Load binder modules
print_step "Loading binder modules..."
if ! lsmod | grep -q binder; then
    print_info "Loading binder_linux and ashmem_linux modules..."
    sudo modprobe binder_linux || print_warning "Failed to load binder_linux (might already be built-in)"
    sudo modprobe ashmem_linux || print_warning "Failed to load ashmem_linux (might already be built-in)"
else
    print_info "Binder modules already loaded"
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
if [[ -d /var/lib/waydroid ]]; then
    print_warning "Waydroid already initialized"
    read -p "Re-initialize? This will reset everything (y/N): " reinit
    if [[ "$reinit" =~ ^[Yy]$ ]]; then
        sudo waydroid init -f
    fi
else
    sudo waydroid init -f
fi
print_success "Waydroid initialized"

# Enable and start services
print_step "Enabling Waydroid services..."
sudo systemctl enable --now waydroid-container.service
sudo systemctl enable --now waydroid-container.socket
sudo systemctl mask waydroid-container-freeze.timer
print_success "Waydroid services enabled"

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
read -p "Install waydroid_script for GApps/ARM translation? (y/N): " install_script
if [[ "$install_script" =~ ^[Yy]$ ]]; then
    SCRIPT_DIR="$HOME/.local/share/waydroid_script"
    
    if [[ -d "$SCRIPT_DIR" ]]; then
        print_info "waydroid_script already exists at $SCRIPT_DIR"
    else
        print_info "Cloning waydroid_script..."
        git clone https://github.com/casualsnek/waydroid_script "$SCRIPT_DIR"
        cd "$SCRIPT_DIR"
        python3 -m venv venv
        venv/bin/pip install -r requirements.txt
    fi
    
    print_info "Launching waydroid_script..."
    print_warning "Use the menu to install GApps and ARM translation"
    cd "$SCRIPT_DIR"
    sudo venv/bin/python3 main.py
fi

# Setup file sharing
print_step "Optional: Setup file sharing with Android"
read -p "Setup ~/Downloads/waydroid folder sharing? (y/N): " setup_share
if [[ "$setup_share" =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/Downloads/waydroid"
    sudo mkdir -p "$HOME/.local/share/waydroid/data/media/0/waydroid"
    
    # Add to fstab
    MOUNT_LINE="$HOME/Downloads/waydroid $HOME/.local/share/waydroid/data/media/0/waydroid none bind 0 0"
    if ! grep -q "waydroid/data/media/0/waydroid" /etc/fstab; then
        print_info "Adding bind mount to /etc/fstab..."
        echo "$MOUNT_LINE" | sudo tee -a /etc/fstab > /dev/null
        sudo mount -a
        print_success "File sharing configured (persistent)"
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
systemctl start waydroid-container.service
waydroid session start
EOF
    sudo chmod +x /usr/local/bin/start-waydroid.sh
    
    # Create desktop entry
    print_info "Creating desktop entry..."
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/waydroid-start.desktop" <<'EOF'
[Desktop Entry]
Name=Start Waydroid
Comment=Start Waydroid container and session
Exec=/usr/local/bin/start-waydroid.sh
Icon=waydroid
Type=Application
Terminal=false
StartupNotify=true
EOF
    chmod +x "$HOME/.local/share/applications/waydroid-start.desktop"
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    
    # Configure sudoers
    print_info "Configuring sudoers for passwordless systemctl..."
    SUDOERS_LINE="$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container.service"
    SUDOERS_FILE="/etc/sudoers.d/waydroid-$USER"
    
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
echo "  2. Or use the 'Start Waydroid' launcher from your app menu"
echo "  3. Install apps: waydroid app install /path/to/app.apk"
echo "  4. List apps: waydroid app list"
echo ""

read -p "Start Waydroid now? (y/N): " start_now
if [[ "$start_now" =~ ^[Yy]$ ]]; then
    print_info "Starting Waydroid session..."
    waydroid session start &
    sleep 2
    waydroid show-full-ui
fi

print_success "Done! Enjoy Waydroid on CachyOS!"
