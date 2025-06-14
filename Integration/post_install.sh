#!/bin/bash

# HyDE-Caelestia Post-Installation Script
# This script runs after the main HyDE installation to set up Caelestia-shell

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYDE_CAELESTIA_DIR="$(dirname "$SCRIPT_DIR")"

print_status "HyDE-Caelestia Post-Installation Setup"
print_status "======================================"

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
    
    cp "$HYDE_CAELESTIA_DIR/Integration/caelestia-shell.service" "$service_dir/"
    
    systemctl --user daemon-reload
    systemctl --user enable caelestia-shell.service
    print_success "Systemd service for Caelestia-shell created and enabled."
    
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
}

# Function to create desktop entry
create_desktop_entry() {
    print_status "Creating desktop entry..."
    
    local desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$desktop_dir"
    cp "$HYDE_CAELESTIA_DIR/Integration/caelestia-shell.desktop" "$desktop_dir/"
    print_success "Desktop entry created."
}

# Main execution
main() {
    print_status "Starting HyDE-Caelestia post-installation setup..."
    
    # Check if we're in the right directory
    if [[ ! -d "$HYDE_CAELESTIA_DIR/Shell" ]]; then
        print_error "Shell directory not found. Please ensure HyDE-Caelestia is correctly set up."
        exit 1
    fi
    
    # Setup Caelestia-shell
    setup_caelestia_shell
    
    # Integrate theme synchronization
    integrate_theme_sync
    
    # Create desktop entry
    create_desktop_entry
    
    print_success "HyDE-Caelestia post-installation setup completed!"
    print_status ""
    print_status "Caelestia-shell will start automatically on next login."
    print_status "You can also start it manually with: systemctl --user start caelestia-shell.service"
    print_status "To sync themes, use: hyde-caelestia-theme-sync apply"
}

# Execute main function
main "$@"

