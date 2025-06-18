#!/bin/bash

# install_caelestia_deps.sh - caelestia-shell 의존성 설치 스크립트
# Hyde-Caelestia 통합 프로젝트

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# global_fn.sh 소스
if ! source "${SCRIPT_DIR}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

echo "=== caelestia-shell 의존성 설치 시작 ==="

# AUR 헬퍼 확인
check_aur_helper() {
    local aur_helpers=("yay" "paru" "pikaur")
    
    for helper in "${aur_helpers[@]}"; do
        if command -v "$helper" &> /dev/null; then
            AUR_HELPER="$helper"
            print_log -g "AUR" " :: " "Found AUR helper: $AUR_HELPER"
            return 0
        fi
    done
    
    print_log -r "AUR" " :: " "No AUR helper found. Installing yay..."
    "${SCRIPT_DIR}/install_aur.sh" "yay-bin"
    AUR_HELPER="yay"
}

# AUR 패키지 설치
install_aur_package() {
    local package="$1"
    
    print_log -g "AUR" " :: " "Installing $package..."
    
    if ! $AUR_HELPER -S "$package" --noconfirm; then
        print_log -r "AUR" " :: " "Failed to install $package"
        return 1
    fi
    
    print_log -g "AUR" " :: " "$package installed successfully"
}

# quickshell 설치
install_quickshell() {
    print_log -g "Quickshell" " :: " "Installing quickshell..."
    
    # quickshell-git 패키지 설치 시도
    if install_aur_package "quickshell-git"; then
        print_log -g "Quickshell" " :: " "quickshell-git installed successfully"
    else
        print_log -y "Quickshell" " :: " "quickshell-git failed, trying quickshell..."
        if install_aur_package "quickshell"; then
            print_log -g "Quickshell" " :: " "quickshell installed successfully"
        else
            print_log -r "Quickshell" " :: " "Failed to install quickshell"
            return 1
        fi
    fi
}

# caelestia-shell 설치
install_caelestia_shell() {
    print_log -g "Caelestia" " :: " "Installing caelestia-shell..."
    
    # caelestia-shell-git 패키지 설치 시도
    if install_aur_package "caelestia-shell-git"; then
        print_log -g "Caelestia" " :: " "caelestia-shell-git installed successfully"
    else
        print_log -y "Caelestia" " :: " "caelestia-shell-git not available, will use local installation"
        return 0
    fi
}

# Qt6 패키지 확인 및 설치
install_qt6_packages() {
    print_log -g "Qt6" " :: " "Checking Qt6 packages..."
    
    local qt6_packages=(
        "qt6-base"
        "qt6-declarative"
        "qt6-svg"
        "qt6-multimedia"
        "qt6-quickcontrols2"
    )
    
    for package in "${qt6_packages[@]}"; do
        if ! pkg_installed "$package"; then
            print_log -g "Qt6" " :: " "Installing $package..."
            if ! pacman -S "$package" --noconfirm; then
                print_log -r "Qt6" " :: " "Failed to install $package"
                return 1
            fi
        else
            print_log -g "Qt6" " :: " "$package already installed"
        fi
    done
}

# 메인 실행
main() {
    print_log -g "Hyde-Caelestia" " :: " "Installing caelestia-shell dependencies..."
    
    # AUR 헬퍼 확인
    check_aur_helper
    
    # Qt6 패키지 설치
    install_qt6_packages
    
    # quickshell 설치
    install_quickshell
    
    # caelestia-shell 설치 (선택사항)
    install_caelestia_shell
    
    print_log -g "Hyde-Caelestia" " :: " "Dependencies installation completed!"
    
    # 설치 확인
    if command -v quickshell &> /dev/null; then
        print_log -g "Verification" " :: " "quickshell is available"
        quickshell --version 2>/dev/null || print_log -y "Verification" " :: " "quickshell version check failed"
    else
        print_log -r "Verification" " :: " "quickshell is not available"
        return 1
    fi
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

