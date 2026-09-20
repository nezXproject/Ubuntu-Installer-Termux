#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu 22.04 Installer for Termux
# Improved version with better error handling and user experience

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UBUNTU_VERSION="22.04"
UBUNTU_CODENAME="jammy"
ROOTFS_URL="https://partner-images.canonical.com/core/${UBUNTU_CODENAME}/current/ubuntu-${UBUNTU_CODENAME}-core-cloudimg-arm64-root.tar.gz"
ROOTFS_URL_AMD64="https://partner-images.canonical.com/core/${UBUNTU_CODENAME}/current/ubuntu-${UBUNTU_CODENAME}-core-cloudimg-amd64-root.tar.gz"
UBUNTU_FS="$HOME/ubuntu-fs"
START_SCRIPT="$HOME/startubuntu.sh"
UNINSTALL_SCRIPT="$HOME/uninstall-ubuntu.sh"

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║     Ubuntu ${UBUNTU_VERSION} Installer for Termux          ║"
    echo "║           by nezXproject                         ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running in Termux
check_termux() {
    if [ ! -d "/data/data/com.termux" ]; then
        log_error "Script ini hanya bisa dijalankan di Termux!"
        exit 1
    fi
    log_info "Termux terdeteksi ✓"
}

# Check architecture
check_architecture() {
    ARCH=$(uname -m)
    case $ARCH in
        aarch64|arm64)
            ARCH_TYPE="arm64"
            DOWNLOAD_URL="$ROOTFS_URL"
            ;;
        x86_64|amd64)
            ARCH_TYPE="amd64"
            DOWNLOAD_URL="$ROOTFS_URL_AMD64"
            ;;
        armv7l|arm)
            log_error "Arsitektur 32-bit (armv7l) tidak didukung."
            log_info "Gunakan perangkat 64-bit atau gunakan Termux dari F-Droid."
            exit 1
            ;;
        *)
            log_error "Arsitektur tidak dikenal: $ARCH"
            exit 1
            ;;
    esac
    log_info "Arsitektur: $ARCH_TYPE ✓"
}

# Check kernel version
check_kernel() {
    KERNEL_VERSION=$(uname -r | cut -d. -f1,2)
    KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
    
    if [ "$KERNEL_MAJOR" -lt 4 ]; then
        log_warn "Kernel terlalu tua ($KERNEL_VERSION). Mungkin perlu konfigurasi tambahan."
        NEED_KERNEL_HACK=true
    else
        log_info "Kernel: $(uname -r) ✓"
        NEED_KERNEL_HACK=false
    fi
}

# Check available space
check_space() {
    AVAILABLE=$(df "$HOME" | tail -1 | awk '{print $4}')
    AVAILABLE_GB=$((AVAILABLE / 1024 / 1024))
    
    if [ "$AVAILABLE_GB" -lt 3 ]; then
        log_error "Ruang penyimpanan tidak cukup!"
        log_info "Dibutuhkan: ~3GB, Tersedia: ${AVAILABLE_GB}GB"
        log_info "Kosongkan ruang penyimpanan terlebih dahulu."
        exit 1
    fi
    log_info "Ruang tersedia: ${AVAILABLE_GB}GB ✓"
}

# Install dependencies
install_dependencies() {
    log_step "Menginstall dependencies..."
    
    pkg update -y 2>/dev/null || true
    pkg install -y proot wget tar 2>/dev/null || {
        log_error "Gagal menginstall dependencies"
        exit 1
    }
    log_info "Dependencies terinstall ✓"
}

# Download rootfs
download_rootfs() {
    log_step "Mendownload Ubuntu ${UBUNTU_VERSION} rootfs..."
    log_info "Ini mungkin memakan waktu 5-15 menit tergantung koneksi internet"
    
    ROOTFS_FILE="$HOME/ubuntu-rootfs.tar.gz"
    
    if [ -f "$ROOTFS_FILE" ]; then
        log_warn "File rootfs sudah ada, menghapus..."
        rm -f "$ROOTFS_FILE"
    fi
    
    wget --progress=bar:force -O "$ROOTFS_FILE" "$DOWNLOAD_URL" || {
        log_error "Gagal mendownload rootfs"
        log_info "Cek koneksi internet Anda dan coba lagi."
        exit 1
    }
    
    log_info "Download selesai ✓"
}

# Extract rootfs
extract_rootfs() {
    log_step "Mengekstrak rootfs..."
    log_info "Ini mungkin memakan waktu 2-5 menit"
    
    if [ -d "$UBUNTU_FS" ]; then
        log_warn "Direktori ubuntu-fs sudah ada, menghapus..."
        rm -rf "$UBUNTU_FS"
    fi
    
    mkdir -p "$UBUNTU_FS"
    
    # Extract with progress
    tar -xzf "$HOME/ubuntu-rootfs.tar.gz" -C "$UBUNTU_FS" 2>/dev/null || {
        log_error "Gagal mengekstrak rootfs"
        exit 1
    }
    
    # Cleanup
    rm -f "$HOME/ubuntu-rootfs.tar.gz"
    
    log_info "Ekstraksi selesai ✓"
}

# Setup DNS
setup_dns() {
    log_step "Mengkonfigurasi DNS..."
    
    # Copy resolv.conf from Termux
    if [ -f "/data/data/com.termux/files/usr/etc/resolv.conf" ]; then
        cp /data/data/com.termux/files/usr/etc/resolv.conf "$UBUNTU_FS/etc/resolv.conf" 2>/dev/null || true
    fi
    
    # Set Google DNS as fallback
    echo "nameserver 8.8.8.8" > "$UBUNTU_FS/etc/resolv.conf"
    echo "nameserver 8.8.4.4" >> "$UBUNTU_FS/etc/resolv.conf"
    
    log_info "DNS dikonfigurasi ✓"
}

# Create start script
create_start_script() {
    log_step "Membuat launcher script..."
    
    if [ "$NEED_KERNEL_HACK" = true ]; then
        PROOT_ARGS="-k 4.14.81"
    else
        PROOT_ARGS=""
    fi
    
    cat > "$START_SCRIPT" << EOF
#!/data/data/com.termux/files/usr/bin/bash

# Ubuntu Launcher for Termux
UBUNTU_FS="\$HOME/ubuntu-fs"

# Check if Ubuntu is installed
if [ ! -d "\$UBUNTU_FS" ]; then
    echo "Ubuntu belum terinstall. Jalankan: bash termux-ubuntu-installer.sh"
    exit 1
fi

# Handle command execution mode
if [ "\$1" = "-c" ]; then
    shift
    proot -r "\$UBUNTU_FS" \\
        -b /dev \\
        -b /sys \\
        -b /proc \\
        -b /data/data/com.termux/files/home:/root \\
        -b /data/data/com.termux/files/usr/tmp:/tmp \\
        -w /root \\
        $PROOT_ARGS \\
        /bin/bash -c "\$*"
else
    proot -r "\$UBUNTU_FS" \\
        -b /dev \\
        -b /sys \\
        -b /proc \\
        -b /data/data/com.termux/files/home:/root \\
        -b /data/data/com.termux/files/usr/tmp:/tmp \\
        -w /root \\
        $PROOT_ARGS \\
        /bin/bash --login
fi
EOF

    chmod +x "$START_SCRIPT"
    log_info "Launcher script dibuat: $START_SCRIPT ✓"
}

# Create uninstall script
create_uninstall_script() {
    log_step "Membuat uninstall script..."
    
    cat > "$UNINSTALL_SCRIPT" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "⚠️  PERINGATAN: Ini akan menghapus semua data Ubuntu!"
echo ""
read -p "Apakah Anda yakin? (y/N): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    rm -rf "$HOME/ubuntu-fs"
    rm -f "$HOME/startubuntu.sh"
    rm -f "$HOME/uninstall-ubuntu.sh"
    echo "✓ Ubuntu berhasil diuninstall."
else
    echo "Dibatalkan."
fi
EOF

    chmod +x "$UNINSTALL_SCRIPT"
    log_info "Uninstall script dibuat: $UNINSTALL_SCRIPT ✓"
}

# Verify installation
verify_installation() {
    log_step "Memverifikasi instalasi..."
    
    if [ ! -d "$UBUNTU_FS" ]; then
        log_error "Direktori ubuntu-fs tidak ditemukan"
        exit 1
    fi
    
    if [ ! -f "$START_SCRIPT" ]; then
        log_error "Launcher script tidak ditemukan"
        exit 1
    fi
    
    # Test run
    log_info "Testing Ubuntu..."
    if "$START_SCRIPT" -c "echo 'Ubuntu test: OK'" 2>/dev/null; then
        log_info "Instalasi verified ✓"
    else
        log_warn "Test run gagal, tapi instalasi mungkin masih berfungsi"
    fi
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          INSTALASI BERHASIL! 🎉                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Untuk memulai Ubuntu:"
    echo -e "  ${YELLOW}~/startubuntu.sh${NC}"
    echo ""
    echo -e "Untuk menjalankan command langsung:"
    echo -e "  ${YELLOW}~/startubuntu.sh -c \"command\"${NC}"
    echo ""
    echo -e "Untuk menguninstall:"
    echo -e "  ${YELLOW}bash ~/uninstall-ubuntu.sh${NC}"
    echo ""
    echo -e "Langkah pertama setelah masuk Ubuntu:"
    echo -e "  ${YELLOW}apt update && apt upgrade -y${NC}"
    echo ""
}

# Main installation
main() {
    print_banner
    
    log_step "Memulai pengecekan sistem..."
    check_termux
    check_architecture
    check_kernel
    check_space
    
    echo ""
    log_step "Memulai instalasi..."
    install_dependencies
    download_rootfs
    extract_rootfs
    setup_dns
    create_start_script
    create_uninstall_script
    verify_installation
    
    show_completion
}

# Run main
main "$@"
