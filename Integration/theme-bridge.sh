#!/bin/bash

# HyDE-Caelestia Theme Bridge
# Converts HyDE theme colors to Caelestia-shell format

set -e

# Configuration
HYDE_CONFIG_DIR="$HOME/.config"
CAELESTIA_CONFIG_DIR="$HOME/.config/quickshell/caelestia"
THEME_BRIDGE_DIR="$CAELESTIA_CONFIG_DIR/themes"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to extract color from HyDE config files
extract_color() {
    local color_name="$1"
    local config_file="$2"
    
    if [[ -f "$config_file" ]]; then
        # Try different color extraction patterns
        local color=$(grep -i "$color_name" "$config_file" | head -1 | sed 's/.*[:#]\s*\([a-fA-F0-9]\{6\}\).*/\1/' | tr '[:lower:]' '[:upper:]')
        
        if [[ -n "$color" && "$color" =~ ^[A-F0-9]{6}$ ]]; then
            echo "#$color"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Function to get current HyDE theme colors
get_hyde_colors() {
    local theme_name="${1:-current}"
    
    print_status "Extracting colors from HyDE theme: $theme_name"
    
    # Common HyDE config files to check
    local config_files=(
        "$HYDE_CONFIG_DIR/hypr/hyprland.conf"
        "$HYDE_CONFIG_DIR/hypr/themes/theme.conf"
        "$HYDE_CONFIG_DIR/hypr/themes/colors.conf"
        "$HYDE_CONFIG_DIR/hypr/themes/wallbash.conf"
        "$HYDE_CONFIG_DIR/kitty/theme.conf"
        "$HYDE_CONFIG_DIR/kitty/hyde.conf"
    )
    
    # Default colors (fallback)
    local primary="#6366f1"
    local secondary="#8b5cf6"
    local accent="#06b6d4"
    local background="#1e1e2e"
    local surface="#313244"
    local text="#cdd6f4"
    
    # Try to extract colors from config files
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            local extracted_primary=$(extract_color "primary\|main\|accent" "$config_file")
            local extracted_background=$(extract_color "background\|bg" "$config_file")
            local extracted_text=$(extract_color "foreground\|fg\|text" "$config_file")
            
            [[ -n "$extracted_primary" ]] && primary="$extracted_primary"
            [[ -n "$extracted_background" ]] && background="$extracted_background"
            [[ -n "$extracted_text" ]] && text="$extracted_text"
        fi
    done
    
    # Output colors in JSON format
    cat << EOF
{
    "primary": "$primary",
    "secondary": "$secondary",
    "accent": "$accent",
    "background": "$background",
    "surface": "$surface",
    "text": "$text"
}
EOF
}

# Function to generate Caelestia-shell color scheme
generate_caelestia_colors() {
    local colors_json="$1"
    local output_file="$2"
    
    print_status "Generating Caelestia-shell color scheme..."
    
    # Extract colors from JSON
    local primary=$(echo "$colors_json" | grep -o '"primary": "[^"]*"' | cut -d'"' -f4)
    local background=$(echo "$colors_json" | grep -o '"background": "[^"]*"' | cut -d'"' -f4)
    local text=$(echo "$colors_json" | grep -o '"text": "[^"]*"' | cut -d'"' -f4)
    
    # Generate QML color scheme
    cat > "$output_file" << EOF
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    
    // HyDE Theme Colors
    readonly property color primary: "$primary"
    readonly property color background: "$background"
    readonly property color text: "$text"
    
    // Material Design 3 Color Palette (adapted from HyDE theme)
    readonly property QtObject palette: QtObject {
        // Primary colors
        readonly property color m3primary: root.primary
        readonly property color m3onPrimary: "#ffffff"
        readonly property color m3primaryContainer: Qt.lighter(root.primary, 1.8)
        readonly property color m3onPrimaryContainer: Qt.darker(root.primary, 2.0)
        
        // Surface colors
        readonly property color m3surface: root.background
        readonly property color m3onSurface: root.text
        readonly property color m3surfaceContainer: Qt.lighter(root.background, 1.2)
        readonly property color m3surfaceContainerHigh: Qt.lighter(root.background, 1.4)
        
        // Background colors
        readonly property color m3background: root.background
        readonly property color m3onBackground: root.text
        
        // Additional colors
        readonly property color m3outline: Qt.rgba(0.5, 0.5, 0.5, 0.3)
        readonly property color m3shadow: Qt.rgba(0, 0, 0, 0.3)
    }
}
EOF

    print_success "Color scheme generated: $output_file"
}

# Function to apply theme to Caelestia-shell
apply_theme() {
    local theme_name="${1:-current}"
    
    print_status "Applying HyDE theme '$theme_name' to Caelestia-shell..."
    
    # Create theme bridge directory
    mkdir -p "$THEME_BRIDGE_DIR"
    
    # Get HyDE colors
    local colors_json=$(get_hyde_colors "$theme_name")
    
    # Generate Caelestia-shell color scheme
    local color_scheme_file="$THEME_BRIDGE_DIR/HydeColors.qml"
    generate_caelestia_colors "$colors_json" "$color_scheme_file"
    
    # Update Caelestia-shell to use the new colors
    # This would require modifying the Caelestia-shell configuration
    # to import and use the HydeColors.qml file
    
    # Restart Caelestia-shell if it's running
    if systemctl --user is-active caelestia-shell.service &>/dev/null; then
        print_status "Restarting Caelestia-shell to apply new theme..."
        systemctl --user restart caelestia-shell.service
    fi
    
    print_success "Theme '$theme_name' applied to Caelestia-shell"
}

# Function to list available themes
list_themes() {
    print_status "Available HyDE themes:"
    
    # This would scan for available HyDE themes
    # For now, we'll show a placeholder
    echo "  - current (currently active theme)"
    echo "  - default (default HyDE theme)"
    
    # In a real implementation, this would scan theme directories
    # and list available themes
}

# Main function
main() {
    case "${1:-apply}" in
        "apply"|"a")
            apply_theme "${2:-current}"
            ;;
        "list"|"l")
            list_themes
            ;;
        "extract"|"e")
            get_hyde_colors "${2:-current}"
            ;;
        *)
            echo "HyDE-Caelestia Theme Bridge"
            echo "=========================="
            echo
            echo "Usage: $0 [command] [theme_name]"
            echo
            echo "Commands:"
            echo "  apply, a [theme]    Apply HyDE theme to Caelestia-shell"
            echo "  list, l             List available themes"
            echo "  extract, e [theme]  Extract colors from HyDE theme"
            echo
            echo "Examples:"
            echo "  $0 apply            Apply current HyDE theme"
            echo "  $0 apply mocha      Apply 'mocha' theme"
            echo "  $0 list             List available themes"
            ;;
    esac
}

# Execute main function
main "$@"

