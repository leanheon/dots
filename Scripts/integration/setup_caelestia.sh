#!/bin/bash

# setup_caelestia.sh - caelestia-shell 초기 설정 스크립트
# Hyde-Caelestia 통합 프로젝트

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYDE_CAELESTIA_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
SHELL_DIR="$HYDE_CAELESTIA_DIR/Shell"

echo "=== caelestia-shell 설정 시작 ==="

# 1. 설정 디렉토리 생성
setup_config_dirs() {
    echo "설정 디렉토리 생성 중..."
    mkdir -p ~/.config/quickshell/caelestia
    mkdir -p ~/.config/hyde/ui
}

# 2. caelestia-shell 파일들 복사
copy_shell_files() {
    echo "caelestia-shell 파일들 복사 중..."
    
    if [[ -d "$SHELL_DIR" ]]; then
        cp -r "$SHELL_DIR"/* ~/.config/quickshell/caelestia/
        echo "caelestia-shell 파일들이 복사되었습니다."
    else
        echo "오류: Shell 디렉토리를 찾을 수 없습니다: $SHELL_DIR"
        exit 1
    fi
}

# 3. Hyde 통합 설정 생성
create_integration_config() {
    echo "Hyde 통합 설정 생성 중..."
    
    cat > ~/.config/hyde/ui/caelestia.conf << 'EOF'
# Hyde-Caelestia 통합 설정
[ui]
shell_type=caelestia
shell_path=~/.config/quickshell/caelestia

[theme_sync]
enabled=true
auto_sync=true

[components]
bar_enabled=true
launcher_enabled=true
notifications_enabled=true
dashboard_enabled=true
session_enabled=true
EOF
    
    echo "Hyde 통합 설정이 생성되었습니다."
}

# 4. systemd 서비스 설정
setup_systemd_service() {
    echo "systemd 서비스 설정 중..."
    
    # caelestia-shell 서비스 파일 생성
    mkdir -p ~/.config/systemd/user
    
    cat > ~/.config/systemd/user/caelestia-shell.service << 'EOF'
[Unit]
Description=Caelestia Shell - Modern Desktop Shell for Hyprland
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/quickshell -c %h/.config/quickshell/caelestia/shell.qml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
    
    # 서비스 활성화
    systemctl --user daemon-reload
    systemctl --user enable caelestia-shell.service
    
    echo "systemd 서비스가 설정되었습니다."
}

# 5. Hyprland 설정 업데이트
update_hyprland_config() {
    echo "Hyprland 설정 업데이트 중..."
    
    local hypr_config="$HOME/.config/hypr/hyprland.conf"
    
    if [[ -f "$hypr_config" ]]; then
        # 기존 UI 컴포넌트 비활성화
        sed -i 's/^exec-once.*waybar/#&/' "$hypr_config"
        sed -i 's/^exec-once.*dunst/#&/' "$hypr_config"
        
        # caelestia-shell 자동 시작 추가
        if ! grep -q "caelestia-shell" "$hypr_config"; then
            echo "" >> "$hypr_config"
            echo "# Hyde-Caelestia Integration" >> "$hypr_config"
            echo "exec-once = systemctl --user start caelestia-shell.service" >> "$hypr_config"
        fi
        
        echo "Hyprland 설정이 업데이트되었습니다."
    else
        echo "경고: Hyprland 설정 파일을 찾을 수 없습니다: $hypr_config"
    fi
}

# 메인 실행
main() {
    echo "Hyde-Caelestia 통합을 위한 caelestia-shell 설정을 시작합니다..."
    
    setup_config_dirs
    copy_shell_files
    create_integration_config
    setup_systemd_service
    update_hyprland_config
    
    echo ""
    echo "=== caelestia-shell 설정 완료 ==="
    echo ""
    echo "다음 단계:"
    echo "1. 시스템을 재시작하거나 다음 명령어로 서비스를 시작하세요:"
    echo "   systemctl --user start caelestia-shell.service"
    echo ""
    echo "2. 테마 동기화를 위해 다음 스크립트를 실행하세요:"
    echo "   $SCRIPT_DIR/theme_bridge.sh"
    echo ""
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

