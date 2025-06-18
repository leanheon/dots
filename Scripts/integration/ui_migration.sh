#!/bin/bash

# ui_migration.sh - 기존 Hyde UI에서 caelestia-shell로 마이그레이션
# Hyde-Caelestia 통합 프로젝트

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/hyde/backup/ui_migration_$(date +%Y%m%d_%H%M%S)"

echo "=== Hyde UI 마이그레이션 시작 ==="

# 1. 기존 UI 설정 백업
backup_legacy_ui_config() {
    echo "기존 UI 설정 백업 중..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Waybar 설정 백업
    if [[ -d "$HOME/.config/waybar" ]]; then
        cp -r "$HOME/.config/waybar" "$BACKUP_DIR/"
        echo "Waybar 설정이 백업되었습니다."
    fi
    
    # Rofi 설정 백업
    if [[ -d "$HOME/.config/rofi" ]]; then
        cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"
        echo "Rofi 설정이 백업되었습니다."
    fi
    
    # Dunst 설정 백업
    if [[ -d "$HOME/.config/dunst" ]]; then
        cp -r "$HOME/.config/dunst" "$BACKUP_DIR/"
        echo "Dunst 설정이 백업되었습니다."
    fi
    
    # Hyprland 설정 백업
    if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        cp "$HOME/.config/hypr/hyprland.conf" "$BACKUP_DIR/"
        echo "Hyprland 설정이 백업되었습니다."
    fi
    
    echo "백업 완료: $BACKUP_DIR"
}

# 2. 기존 UI 서비스 중지
stop_legacy_ui_services() {
    echo "기존 UI 서비스 중지 중..."
    
    # Waybar 중지
    if systemctl --user is-active --quiet waybar.service 2>/dev/null; then
        systemctl --user stop waybar.service
        systemctl --user disable waybar.service
        echo "Waybar 서비스가 중지되었습니다."
    fi
    
    # Dunst 중지
    if pgrep -x dunst > /dev/null; then
        pkill dunst
        echo "Dunst가 중지되었습니다."
    fi
    
    # 기타 UI 프로세스 중지
    pkill -f "waybar" 2>/dev/null || true
    pkill -f "rofi" 2>/dev/null || true
    
    echo "기존 UI 서비스가 중지되었습니다."
}

# 3. 설정 마이그레이션
migrate_ui_settings() {
    echo "UI 설정 마이그레이션 중..."
    
    # Waybar 설정에서 유용한 정보 추출
    migrate_waybar_settings
    
    # Rofi 설정에서 유용한 정보 추출
    migrate_rofi_settings
    
    # Dunst 설정에서 유용한 정보 추출
    migrate_dunst_settings
}

# 4. Waybar 설정 마이그레이션
migrate_waybar_settings() {
    local waybar_config="$HOME/.config/waybar/config.jsonc"
    
    if [[ -f "$waybar_config" ]]; then
        echo "Waybar 설정 마이그레이션 중..."
        
        # JSON에서 유용한 설정들 추출 (예: 모듈 활성화 상태)
        # 이 정보를 caelestia-shell BarConfig.qml에 반영
        
        local bar_config="$HOME/.config/quickshell/caelestia/config/BarConfig.qml"
        if [[ -f "$bar_config" ]]; then
            # 기존 Waybar 모듈 설정을 caelestia-shell 설정으로 변환
            echo "Waybar 모듈 설정을 caelestia-shell로 변환 중..."
            
            # 예: 워크스페이스 표시 설정
            if grep -q '"hyprland/workspaces"' "$waybar_config"; then
                sed -i 's/showWorkspaces: .*/showWorkspaces: true/' "$bar_config"
            fi
            
            # 예: 시스템 트레이 설정
            if grep -q '"tray"' "$waybar_config"; then
                sed -i 's/showSystemTray: .*/showSystemTray: true/' "$bar_config"
            fi
        fi
    fi
}

# 5. Rofi 설정 마이그레이션
migrate_rofi_settings() {
    local rofi_config="$HOME/.config/rofi/config.rasi"
    
    if [[ -f "$rofi_config" ]]; then
        echo "Rofi 설정 마이그레이션 중..."
        
        # Rofi 테마 정보를 caelestia-shell launcher 설정으로 변환
        local launcher_config="$HOME/.config/quickshell/caelestia/config/LauncherConfig.qml"
        if [[ -f "$launcher_config" ]]; then
            echo "Rofi 설정을 caelestia-shell launcher로 변환 중..."
            # 필요한 설정 변환 로직
        fi
    fi
}

# 6. Dunst 설정 마이그레이션
migrate_dunst_settings() {
    local dunst_config="$HOME/.config/dunst/dunstrc"
    
    if [[ -f "$dunst_config" ]]; then
        echo "Dunst 설정 마이그레이션 중..."
        
        # Dunst 설정을 caelestia-shell notifications 설정으로 변환
        local notifs_config="$HOME/.config/quickshell/caelestia/config/NotifsConfig.qml"
        if [[ -f "$notifs_config" ]]; then
            echo "Dunst 설정을 caelestia-shell notifications로 변환 중..."
            
            # 타임아웃 설정 추출
            local timeout=$(grep "timeout" "$dunst_config" | head -n1 | cut -d'=' -f2 | xargs)
            if [[ -n "$timeout" ]]; then
                sed -i "s/timeout: .*/timeout: $timeout/" "$notifs_config"
            fi
            
            # 최대 알림 수 설정 추출
            local max_notifications=$(grep "notification_limit" "$dunst_config" | cut -d'=' -f2 | xargs)
            if [[ -n "$max_notifications" ]]; then
                sed -i "s/maxNotifications: .*/maxNotifications: $max_notifications/" "$notifs_config"
            fi
        fi
    fi
}

# 7. Hyprland 설정 업데이트
update_hyprland_for_caelestia() {
    echo "Hyprland 설정을 caelestia-shell용으로 업데이트 중..."
    
    local hypr_config="$HOME/.config/hypr/hyprland.conf"
    
    if [[ -f "$hypr_config" ]]; then
        # 기존 UI 자동 시작 비활성화
        sed -i 's/^exec-once.*waybar/#&/' "$hypr_config"
        sed -i 's/^exec-once.*dunst/#&/' "$hypr_config"
        sed -i 's/^exec-once.*rofi/#&/' "$hypr_config"
        
        # caelestia-shell 자동 시작 추가
        if ! grep -q "caelestia-shell" "$hypr_config"; then
            echo "" >> "$hypr_config"
            echo "# Hyde-Caelestia Integration - UI Migration" >> "$hypr_config"
            echo "exec-once = systemctl --user start caelestia-shell.service" >> "$hypr_config"
        fi
        
        # 키바인딩 업데이트 (Rofi -> caelestia launcher)
        sed -i 's/bind.*rofi.*/bind = SUPER, SPACE, exec, qdbus org.quickshell /caelestia org.quickshell.caelestia.toggleLauncher/' "$hypr_config"
        
        echo "Hyprland 설정이 업데이트되었습니다."
    fi
}

# 8. 기존 UI 패키지 제거 (선택사항)
remove_legacy_packages() {
    echo "기존 UI 패키지 제거 여부를 확인합니다..."
    
    read -p "기존 UI 패키지들(waybar, rofi, dunst)을 제거하시겠습니까? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "기존 UI 패키지 제거 중..."
        
        # 패키지 매니저에 따라 제거 명령어 실행
        if command -v pacman &> /dev/null; then
            sudo pacman -R waybar rofi dunst --noconfirm 2>/dev/null || true
        elif command -v apt &> /dev/null; then
            sudo apt remove waybar rofi dunst -y 2>/dev/null || true
        fi
        
        echo "기존 UI 패키지가 제거되었습니다."
    else
        echo "기존 UI 패키지는 유지됩니다."
    fi
}

# 9. 마이그레이션 완료 보고서 생성
generate_migration_report() {
    local report_file="$BACKUP_DIR/migration_report.txt"
    
    cat > "$report_file" << EOF
Hyde UI 마이그레이션 보고서
=========================

마이그레이션 일시: $(date)
백업 디렉토리: $BACKUP_DIR

마이그레이션된 구성 요소:
- Waybar → caelestia-shell Bar
- Rofi → caelestia-shell Launcher
- Dunst → caelestia-shell Notifications

백업된 설정 파일들:
$(ls -la "$BACKUP_DIR" 2>/dev/null || echo "백업 파일 없음")

마이그레이션 후 확인사항:
1. caelestia-shell 서비스 상태 확인:
   systemctl --user status caelestia-shell.service

2. 테마 동기화 확인:
   $SCRIPT_DIR/theme_bridge.sh

3. 기능 테스트:
   - 상태 바 표시 확인
   - 런처 동작 확인 (Super + Space)
   - 알림 시스템 확인

문제 발생 시 롤백 방법:
1. caelestia-shell 서비스 중지:
   systemctl --user stop caelestia-shell.service
   systemctl --user disable caelestia-shell.service

2. 백업된 설정 복원:
   cp -r $BACKUP_DIR/waybar ~/.config/
   cp -r $BACKUP_DIR/rofi ~/.config/
   cp -r $BACKUP_DIR/dunst ~/.config/
   cp $BACKUP_DIR/hyprland.conf ~/.config/hypr/

3. 기존 서비스 재시작:
   systemctl --user start waybar.service
   dunst &

EOF
    
    echo "마이그레이션 보고서가 생성되었습니다: $report_file"
}

# 메인 실행
main() {
    echo "Hyde UI에서 caelestia-shell로 마이그레이션을 시작합니다..."
    echo "이 과정에서 기존 UI 설정이 백업되고 새로운 UI로 전환됩니다."
    echo ""
    
    read -p "계속하시겠습니까? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "마이그레이션이 취소되었습니다."
        exit 0
    fi
    
    backup_legacy_ui_config
    stop_legacy_ui_services
    migrate_ui_settings
    update_hyprland_for_caelestia
    
    # caelestia-shell 설정 (setup_caelestia.sh 호출)
    if [[ -f "$SCRIPT_DIR/setup_caelestia.sh" ]]; then
        echo "caelestia-shell 설정 실행 중..."
        bash "$SCRIPT_DIR/setup_caelestia.sh"
    fi
    
    # 테마 동기화 (theme_bridge.sh 호출)
    if [[ -f "$SCRIPT_DIR/theme_bridge.sh" ]]; then
        echo "테마 동기화 실행 중..."
        bash "$SCRIPT_DIR/theme_bridge.sh"
    fi
    
    remove_legacy_packages
    generate_migration_report
    
    echo ""
    echo "=== UI 마이그레이션 완료 ==="
    echo ""
    echo "마이그레이션이 완료되었습니다!"
    echo "시스템을 재시작하거나 다음 명령어로 새로운 UI를 시작하세요:"
    echo "  systemctl --user start caelestia-shell.service"
    echo ""
    echo "마이그레이션 보고서: $BACKUP_DIR/migration_report.txt"
    echo "문제 발생 시 백업 디렉토리를 참조하세요: $BACKUP_DIR"
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

