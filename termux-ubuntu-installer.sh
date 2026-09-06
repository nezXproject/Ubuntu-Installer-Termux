#!/bin/bash

##############################################################################
# Termux Ubuntu 22.04 Installer
# 
# Installs Ubuntu 22.04 LTS in Termux without requiring root access.
# Works on any Android device running Termux.
#
# Features:
# - Downloads everything automatically
# - Handles old kernel compatibility
# - Creates easy launch scripts
# - Beginner-friendly progress messages
#
# License: MIT
##############################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$HOME/ubuntu-fs"
UBUNTU_VERSION="22.04"
UBUNTU_ARCH=$(getprop ro.product.cpu.abi 2>/dev/null || echo "unknown")

##############################################################################
# Helper Functions
##############################################################################

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[→]${NC} $1"
}

##############################################################################
# Pre-installation Checks
##############################################################################

check_termux_environment() {
    print_header "Checking Termux Environment"
    
    # Check if running in Termux
    if [ ! -d "$PREFIX" ]; then
        print_error "This script must be run in Termux!"
        exit 1
    fi
    print_info "Termux environment detected"
    
    # Check disk space (need at least 3GB for Ubuntu 22.04)
    AVAILABLE_SPACE=$(df $HOME | awk 'NR==2 {print $4}')
    AVAILABLE_GB=$((AVAILABLE_SPACE / 1024 / 1024))
    
    if [ "$AVAILABLE_GB" -lt 3 ]; then
        print_warning "Low disk space: ${AVAILABLE_GB}GB available"
        print_warning "Ubuntu 22.04 needs at least 3GB. Installation may fail."
        echo -n "Continue anyway? (y/n) "
        read -r response
        if [ "$response" != "y" ]; then
            exit 1
        fi
    else
        print_info "Disk space: ${AVAILABLE_GB}GB available (sufficient)"
    fi
    
    # Detect device architecture
    case "$UBUNTU_ARCH" in
        arm64-v8a|aarch64)
            UBUNTU_ARCH="arm64"
            print_info "Device architecture: ARM64 (aarch64)"
            ;;
        armeabi-v7a)
            UBUNTU_ARCH="armhf"
            print_warning "Device architecture: ARMv7 (32-bit)"
            print_warning "Not officially supported, but may work"
            ;;
        x86_64)
            UBUNTU_ARCH="amd64"
            print_info "Device architecture: x86_64"
            ;;
        x86)
            UBUNTU_ARCH="i386"
            print_warning "Device architecture: x86 (32-bit)"
            print_warning "Not officially supported, but may work"
            ;;
        *)
            print_error "Unknown architecture: $UBUNTU_ARCH"
            exit 1
            ;;
    esac
}

check_required_tools() {
    print_step "Checking required tools..."
    
    local missing_tools=0
    
    for tool in proot wget; do
        if ! command -v "$tool" &> /dev/null; then
            print_warning "Missing: $tool"
            missing_tools=1
        else
            print_info "Found: $tool"
        fi
    done
    
    if [ "$missing_tools" -eq 1 ]; then
        print_error "Installing missing tools..."
        apt-get update
        apt-get install -y proot wget
        print_info "Tools installed successfully"
    fi
}

##############################################################################
# Download Ubuntu Rootfs
##############################################################################

download_ubuntu_rootfs() {
    print_header "Downloading Ubuntu 22.04 Rootfs"
    
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Installation directory already exists: $INSTALL_DIR"
        echo -n "Delete and reinstall? (y/n) "
        read -r response
        if [ "$response" = "y" ]; then
            print_step "Removing existing installation..."
            rm -rf "$INSTALL_DIR"
        else
            print_info "Keeping existing installation"
            return
        fi
    fi
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    print_step "Selecting download mirror based on architecture..."
    
    # Ubuntu rootfs URLs (using official Ubuntu cloud images)
    case "$UBUNTU_ARCH" in
        arm64)
            ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.1-base-arm64.tar.gz"
            ;;
        armhf)
            ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.1-base-armhf.tar.gz"
            ;;
        amd64)
            ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.1-base-amd64.tar.gz"
            ;;
        i386)
            ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.1-base-i386.tar.gz"
            ;;
    esac
    
    print_info "Download URL: $ROOTFS_URL"
    print_step "Downloading rootfs (~500MB, may take several minutes)..."
    
    # Use wget with progress bar and resume capability
    if ! wget --show-progress -c "$ROOTFS_URL" -O ubuntu-rootfs.tar.gz; then
        print_error "Download failed!"
        print_error "Possible causes:"
        print_error "  - No internet connection"
        print_error "  - URL is outdated"
        print_error "  - Server is down"
        print_error "  - Download incomplete (try running the script again)"
        exit 1
    fi
    
    print_info "Download complete"
    
    print_step "Extracting rootfs (this takes 2-5 minutes)..."
    if ! tar -xzf ubuntu-rootfs.tar.gz; then
        print_error "Extraction failed!"
        exit 1
    fi
    
    print_info "Extraction complete"
    rm ubuntu-rootfs.tar.gz
}

##############################################################################
# Setup and Configuration
##############################################################################

setup_ubuntu_environment() {
    print_header "Setting Up Ubuntu Environment"
    
    # Create startup script
    print_step "Creating Ubuntu launcher script..."
    
    cat > "$HOME/startubuntu.sh" << 'EOF'
#!/bin/bash

# Ubuntu 22.04 Launcher for Termux
# This script starts your Ubuntu environment

UBUNTU_FS="$HOME/ubuntu-fs"

if [ ! -d "$UBUNTU_FS" ]; then
    echo "Error: Ubuntu installation not found at $UBUNTU_FS"
    echo "Please run the installer first."
    exit 1
fi

# For older devices/kernels, uncomment the line below (remove the # )
# If you get "Fatal Kernel too old" errors, use this
# PROOT_ARGS="-k 4.14.81"

# Start Ubuntu with proot
proot ${PROOT_ARGS} \
    -r "$UBUNTU_FS" \
    -b /dev \
    -b /sys \
    -b /proc \
    -w /root \
    /bin/bash --login

EOF
    
    chmod +x "$HOME/startubuntu.sh"
    print_info "Launcher created: $HOME/startubuntu.sh"
    
    # Create helper script for uninstalling
    print_step "Creating uninstall script..."
    
    cat > "$HOME/uninstall-ubuntu.sh" << 'EOF'
#!/bin/bash

echo "⚠️  This will delete your Ubuntu installation!"
echo "All files in ~/ubuntu-fs will be removed."
echo -n "Type 'yes' to confirm: "
read confirmation

if [ "$confirmation" = "yes" ]; then
    echo "Removing Ubuntu installation..."
    rm -rf ~/ubuntu-fs
    echo "✓ Ubuntu has been uninstalled."
    echo ""
    echo "To reinstall, run the installer script again:"
    echo "  bash termux-ubuntu-installer.sh"
else
    echo "Cancelled."
fi

EOF
    
    chmod +x "$HOME/uninstall-ubuntu.sh"
    print_info "Uninstaller created: $HOME/uninstall-ubuntu.sh"
}

##############################################################################
# Kernel Compatibility Handling
##############################################################################

check_kernel_compatibility() {
    print_header "Checking Kernel Compatibility"
    
    KERNEL_VERSION=$(uname -r | cut -d. -f1-2)
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
    KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d. -f2)
    
    print_info "Detected kernel version: $KERNEL_VERSION"
    
    # Check if kernel is older than 4.4 (potential issue)
    if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 4 ]); then
        print_warning "Old kernel detected (< 4.4)"
        print_warning "You may need to enable kernel compatibility mode."
        print_warning ""
        print_warning "If you get 'Fatal Kernel too old' error when starting Ubuntu:"
        print_warning "  1. Edit: startubuntu.sh"
        print_warning "  2. Find the line: # PROOT_ARGS=\"-k 4.14.81\""
        print_warning "  3. Remove the # at the start to enable it"
        print_warning "  4. Save and try running Ubuntu again"
        echo ""
        echo -n "Press Enter to continue..."
        read
    else
        print_info "Kernel is compatible (>= 4.4)"
    fi
}

##############################################################################
# Post-Installation Verification
##############################################################################

verify_installation() {
    print_header "Verifying Installation"
    
    if [ ! -d "$INSTALL_DIR/bin" ] || [ ! -d "$INSTALL_DIR/etc" ]; then
        print_error "Installation appears incomplete!"
        exit 1
    fi
    
    print_info "Core directories verified"
    
    # Quick test of proot
    print_step "Testing proot with Ubuntu environment..."
    
    if proot -r "$INSTALL_DIR" /bin/ls / > /dev/null 2>&1; then
        print_info "PRoot test successful"
    else
        print_warning "PRoot test failed (this may still work)"
    fi
}

##############################################################################
# Final Instructions
##############################################################################

show_completion_message() {
    print_header "Installation Complete!"
    
    echo ""
    echo -e "${GREEN}Ubuntu 22.04 LTS is ready to use!${NC}"
    echo ""
    echo "📍 Installation location: $INSTALL_DIR"
    echo "   Size: $(du -sh $INSTALL_DIR 2>/dev/null | cut -f1)"
    echo ""
    echo "🚀 ${GREEN}To start Ubuntu, run:${NC}"
    echo "   $HOME/startubuntu.sh"
    echo ""
    echo "📝 ${GREEN}Other useful commands:${NC}"
    echo "   • Inside Ubuntu: exit          (to return to Termux)"
    echo "   • From Termux:   bash ~/uninstall-ubuntu.sh  (to remove Ubuntu)"
    echo ""
    echo "⚙️  ${GREEN}First-time setup tips:${NC}"
    echo "   1. After starting Ubuntu, update packages:"
    echo "      apt update && apt upgrade -y"
    echo "   2. Install useful tools:"
    echo "      apt install build-essential python3 git nano"
    echo "   3. Create a regular user (optional but recommended):"
    echo "      adduser ubuntu"
    echo ""
    echo "⚠️  ${YELLOW}Important notes:${NC}"
    echo "   • Ubuntu shares Android's kernel - you can't update it"
    echo "   • Some system services may not work (systemd, docker, etc.)"
    echo "   • All file paths are relative to the proot environment"
    echo "   • If you see 'Kernel too old' error, see startubuntu.sh"
    echo ""
    echo "📚 ${BLUE}For more info:${NC}"
    echo "   https://wiki.termux.com/wiki/PRoot"
    echo ""
}

##############################################################################
# Main Execution
##############################################################################

main() {
    clear
    print_header "Termux Ubuntu 22.04 Installer"
    echo ""
    echo "This script will install Ubuntu 22.04 LTS in Termux."
    echo "No root access required!"
    echo ""
    
    check_termux_environment
    echo ""
    
    check_required_tools
    echo ""
    
    download_ubuntu_rootfs
    echo ""
    
    setup_ubuntu_environment
    echo ""
    
    check_kernel_compatibility
    echo ""
    
    verify_installation
    echo ""
    
    show_completion_message
}

# Run main function
main

exit 0
