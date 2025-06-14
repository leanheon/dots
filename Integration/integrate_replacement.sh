#!/bin/bash

# HyDE-Caelestia UI Replacement and Integration Script
# This script replaces HyDE's default UI components with Caelestia-shell

set -e

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

# Function to print colored output
print_status() {
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYDE_CAELESTIA_DIR="$(dirname "$SCRIPT_DIR")"

print_status "HyDE-Caelestia UI Replacement and Integration Script"
print_status "=================================================="

# Function to install Quickshell dependencies
install_quickshell_deps() {
    print_status "Installing Quickshell and Qt6 dependencies..."
    
    # Check if paru is available
    if command -v paru &> /dev/null; then
        paru -S --needed quickshell-git qt6-declarative qt6-wayland qt6-svg qt6-multimedia
    elif command -v yay &> /dev/null; then
        yay -S --needed quickshell-git qt6-declarative qt6-wayland qt6-svg qt6-multimedia
    else
        print_warning "AUR helper (paru/yay) not found. Please install Quickshell and Qt6 dependencies manually:"
        print_warning "  - quickshell-git"
        print_warning "  - qt6-declarative"
        print_warning "  - qt6-wayland"
        print_warning "  - qt6-svg"
        print_warning "  - qt6-multimedia"
        print_warning "You can find quickshell-git on AUR: git clone https://aur.archlinux.org/quickshell-git.git"
        print_warning "cd quickshell-git && makepkg -si"
    fi
}

# Function to disable/remove existing HyDE UI components
disable_hyde_ui() {
    print_status "Disabling/removing existing HyDE UI components (Waybar, Rofi, Dunst)..."
    
    # Stop and disable Waybar service if it exists
    if systemctl --user is-active --quiet waybar.service; then
        systemctl --user stop waybar.service
        systemctl --user disable waybar.service
        print_success "Waybar service stopped and disabled."
    fi
    
    # Remove/backup Waybar config files
    if [[ -d "$HOME/.config/waybar" ]]; then
        mv "$HOME/.config/waybar" "$HOME/.config/waybar.backup.$(date +%s)"
        print_warning "Existing Waybar config backed up."
    fi
    
    # Remove/backup Rofi config files
    if [[ -d "$HOME/.config/rofi" ]]; then
        mv "$HOME/.config/rofi" "$HOME/.config/rofi.backup.$(date +%s)"
        print_warning "Existing Rofi config backed up."
    fi
    
    # Remove/backup Dunst config files
    if [[ -d "$HOME/.config/dunst" ]]; then
        mv "$HOME/.config/dunst" "$HOME/.config/dunst.backup.$(date +%s)"
        print_warning "Existing Dunst config backed up."
    fi
    
    # Remove/backup Hyprland exec-once entries for Waybar/Rofi/Dunst
    local hyprland_config="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$hyprland_config" ]]; then
        sed -i 
            -e "/exec-once = waybar/d" 
            -e "/exec-once = rofi/d" 
            -e "/exec-once = dunst/d" 
            "$hyprland_config"
        print_success "Removed Waybar, Rofi, Dunst exec-once entries from Hyprland config."
    fi
    
    print_success "Existing HyDE UI components disabled/removed."
}

# Function to setup Caelestia-shell configuration
setup_caelestia_shell() {
    print_status "Setting up Caelestia-shell as the primary UI..."
    
    local config_dir="$HOME/.config/quickshell"
    local caelestia_config_dir="$config_dir/caelestia"
    
    # Create quickshell config directory
    mkdir -p "$config_dir"
    
    # Create symlink to shell directory
    if [[ -L "$caelestia_config_dir" ]]; then
        rm "$caelestia_config_dir"
    elif [[ -d "$caelestia_config_dir" ]]; then
        mv "$caelestia_config_dir" "$caelestia_config_dir.backup.$(date +%s)"
        print_warning "Existing caelestia config backed up."
    fi
    
    ln -sf "$HYDE_CAELESTIA_DIR/Shell" "$caelestia_config_dir"
    print_success "Caelestia-shell configuration linked to $caelestia_config_dir"
    
    # Create and enable systemd service for Caelestia-shell
    local service_dir="$HOME/.config/systemd/user"
    mkdir -p "$service_dir"
    
    cat > "$service_dir/caelestia-shell.service" << EOF
[Unit]
Description=Caelestia Shell
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/quickshell -c caelestia
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable caelestia-shell.service
    systemctl --user start caelestia-shell.service
    print_success "Systemd service for Caelestia-shell created, enabled, and started."
    
    # Add exec-once for Caelestia-shell to Hyprland config
    local hyprland_config="$HOME/.config/hypr/hyprland.conf"
    if [[ -f "$hyprland_config" ]]; then
        if ! grep -q "exec-once = quickshell -c caelestia" "$hyprland_config"; then
            echo "exec-once = quickshell -c caelestia" >> "$hyprland_config"
            print_success "Added Caelestia-shell exec-once entry to Hyprland config."
        else
            print_warning "Caelestia-shell exec-once entry already exists in Hyprland config."
        fi
    else
        print_warning "Hyprland config not found at $hyprland_config. Please add 'exec-once = quickshell -c caelestia' manually."
    fi
}

# Function to integrate theme synchronization
integrate_theme_sync() {
    print_status "Integrating theme synchronization..."
    
    # Copy theme-bridge.sh to a common bin directory
    local local_bin_dir="$HOME/.local/bin"
    mkdir -p "$local_bin_dir"
    cp "$HYDE_CAELESTIA_DIR/Integration/theme-bridge.sh" "$local_bin_dir/hyde-caelestia-theme-sync"
    chmod +x "$local_bin_dir/hyde-caelestia-theme-sync"
    print_success "Theme synchronization script copied to $local_bin_dir/hyde-caelestia-theme-sync."
    
    print_warning "Theme synchronization is a placeholder. Manual adjustments may be needed."
}

# Main execution
main() {
    print_status "Starting HyDE-Caelestia UI replacement and integration..."
    
    # Check if we're in the right directory
    if [[ ! -d "$HYDE_CAELESTIA_DIR/Shell" ]]; then
        print_error "Shell directory not found. Please run this script from the Integration directory or ensure HyDE-Caelestia is correctly set up."
        exit 1
    fi
    
    # Install dependencies
    install_quickshell_deps
    
    # Disable/remove existing HyDE UI components
    disable_hyde_ui
    
    # Setup Caelestia-shell
    setup_caelestia_shell
    
    # Integrate theme synchronization
    integrate_theme_sync
    
    print_success "HyDE-Caelestia UI replacement and integration completed!"
    print_status ""
    print_status "Please reboot your system for changes to take full effect."
}

# Execute main function
main "$@"

