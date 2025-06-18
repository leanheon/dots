#!/bin/bash

# theme_bridge.sh - Hyde와 caelestia-shell 테마 연동 스크립트
# Hyde-Caelestia 통합 프로젝트

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYDE_CONFIG_DIR="$HOME/.config/hyde"
CAELESTIA_CONFIG_DIR="$HOME/.config/quickshell/caelestia/config"

echo "=== Hyde-Caelestia 테마 동기화 시작 ==="

# 1. Hyde 테마 정보 추출
extract_hyde_theme() {
    local theme_name="${1:-$(get_current_hyde_theme)}"
    
    echo "Hyde 테마 정보 추출 중: $theme_name"
    
    # Hyde 테마 디렉토리 확인
    local theme_dir="$HYDE_CONFIG_DIR/themes/$theme_name"
    if [[ ! -d "$theme_dir" ]]; then
        echo "오류: Hyde 테마를 찾을 수 없습니다: $theme_name"
        echo "사용 가능한 테마들:"
        ls "$HYDE_CONFIG_DIR/themes/" 2>/dev/null || echo "테마 디렉토리가 없습니다."
        exit 1
    fi
    
    # 색상 정보 파일들 확인
    local color_files=(
        "$theme_dir/colors.conf"
        "$theme_dir/theme.conf"
        "$theme_dir/hyprland.conf"
    )
    
    for file in "${color_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "색상 파일 발견: $file"
            parse_color_file "$file"
        fi
    done
}

# 2. 현재 Hyde 테마 가져오기
get_current_hyde_theme() {
    local current_theme_file="$HYDE_CONFIG_DIR/current_theme"
    
    if [[ -f "$current_theme_file" ]]; then
        cat "$current_theme_file"
    else
        # 기본 테마 또는 첫 번째 테마 사용
        local first_theme=$(ls "$HYDE_CONFIG_DIR/themes/" | head -n1)
        echo "${first_theme:-default}"
    fi
}

# 3. 색상 파일 파싱
parse_color_file() {
    local file="$1"
    
    echo "색상 파일 파싱 중: $file"
    
    # 일반적인 색상 변수들 추출
    if [[ -f "$file" ]]; then
        # 색상 변수들을 전역 변수로 설정
        while IFS='=' read -r key value; do
            # 주석과 빈 줄 제거
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # 값에서 따옴표와 공백 제거
            value=$(echo "$value" | sed 's/[";]//g' | xargs)
            
            case "$key" in
                *primary*|*PRIMARY*)
                    HYDE_PRIMARY_COLOR="$value"
                    ;;
                *secondary*|*SECONDARY*)
                    HYDE_SECONDARY_COLOR="$value"
                    ;;
                *accent*|*ACCENT*)
                    HYDE_ACCENT_COLOR="$value"
                    ;;
                *background*|*BACKGROUND*|*bg*)
                    HYDE_BACKGROUND_COLOR="$value"
                    ;;
                *foreground*|*FOREGROUND*|*fg*)
                    HYDE_FOREGROUND_COLOR="$value"
                    ;;
                *surface*|*SURFACE*)
                    HYDE_SURFACE_COLOR="$value"
                    ;;
            esac
        done < "$file"
    fi
}

# 4. caelestia-shell 테마 적용
apply_caelestia_theme() {
    echo "caelestia-shell 테마 적용 중..."
    
    # 기본값 설정
    HYDE_PRIMARY_COLOR="${HYDE_PRIMARY_COLOR:-#6366f1}"
    HYDE_SECONDARY_COLOR="${HYDE_SECONDARY_COLOR:-#8b5cf6}"
    HYDE_ACCENT_COLOR="${HYDE_ACCENT_COLOR:-#06b6d4}"
    HYDE_BACKGROUND_COLOR="${HYDE_BACKGROUND_COLOR:-#0f172a}"
    HYDE_FOREGROUND_COLOR="${HYDE_FOREGROUND_COLOR:-#f8fafc}"
    HYDE_SURFACE_COLOR="${HYDE_SURFACE_COLOR:-#1e293b}"
    
    echo "적용할 색상들:"
    echo "  Primary: $HYDE_PRIMARY_COLOR"
    echo "  Secondary: $HYDE_SECONDARY_COLOR"
    echo "  Accent: $HYDE_ACCENT_COLOR"
    echo "  Background: $HYDE_BACKGROUND_COLOR"
    echo "  Foreground: $HYDE_FOREGROUND_COLOR"
    echo "  Surface: $HYDE_SURFACE_COLOR"
    
    # Appearance.qml 업데이트
    update_appearance_config
    
    # 기타 설정 파일들 업데이트
    update_component_configs
}

# 5. Appearance.qml 업데이트
update_appearance_config() {
    local appearance_file="$CAELESTIA_CONFIG_DIR/Appearance.qml"
    
    if [[ ! -f "$appearance_file" ]]; then
        echo "Appearance.qml 파일을 찾을 수 없습니다. 기본 파일을 생성합니다."
        create_default_appearance_config
    fi
    
    echo "Appearance.qml 업데이트 중..."
    
    # 백업 생성
    cp "$appearance_file" "$appearance_file.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 색상 값들 업데이트 (QML 형식으로)
    sed -i "s/property color primaryColor:.*/property color primaryColor: \"$HYDE_PRIMARY_COLOR\"/" "$appearance_file"
    sed -i "s/property color secondaryColor:.*/property color secondaryColor: \"$HYDE_SECONDARY_COLOR\"/" "$appearance_file"
    sed -i "s/property color accentColor:.*/property color accentColor: \"$HYDE_ACCENT_COLOR\"/" "$appearance_file"
    sed -i "s/property color backgroundColor:.*/property color backgroundColor: \"$HYDE_BACKGROUND_COLOR\"/" "$appearance_file"
    sed -i "s/property color foregroundColor:.*/property color foregroundColor: \"$HYDE_FOREGROUND_COLOR\"/" "$appearance_file"
    sed -i "s/property color surfaceColor:.*/property color surfaceColor: \"$HYDE_SURFACE_COLOR\"/" "$appearance_file"
    
    echo "Appearance.qml이 업데이트되었습니다."
}

# 6. 기본 Appearance.qml 생성
create_default_appearance_config() {
    mkdir -p "$CAELESTIA_CONFIG_DIR"
    
    cat > "$CAELESTIA_CONFIG_DIR/Appearance.qml" << 'EOF'
import QtQuick

QtObject {
    // Hyde 테마 연동 색상들
    property color primaryColor: "#6366f1"
    property color secondaryColor: "#8b5cf6"
    property color accentColor: "#06b6d4"
    property color backgroundColor: "#0f172a"
    property color foregroundColor: "#f8fafc"
    property color surfaceColor: "#1e293b"
    
    // Material Design 3 색상 변형들
    property color onPrimary: "#ffffff"
    property color onSecondary: "#ffffff"
    property color onBackground: foregroundColor
    property color onSurface: foregroundColor
    
    // 투명도 변형들
    property color primaryContainer: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.12)
    property color secondaryContainer: Qt.rgba(secondaryColor.r, secondaryColor.g, secondaryColor.b, 0.12)
    property color surfaceVariant: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.8)
    
    // 테마 정보
    property string themeName: "Hyde-Caelestia"
    property bool isDarkTheme: true
    property real borderRadius: 12
    property real elevation: 4
}
EOF
}

# 7. 컴포넌트별 설정 업데이트
update_component_configs() {
    echo "컴포넌트별 설정 업데이트 중..."
    
    # Bar 설정 업데이트
    if [[ -f "$CAELESTIA_CONFIG_DIR/BarConfig.qml" ]]; then
        echo "Bar 설정 업데이트 중..."
        # Bar 관련 색상 설정 업데이트 로직
    fi
    
    # Launcher 설정 업데이트
    if [[ -f "$CAELESTIA_CONFIG_DIR/LauncherConfig.qml" ]]; then
        echo "Launcher 설정 업데이트 중..."
        # Launcher 관련 색상 설정 업데이트 로직
    fi
    
    # Notifications 설정 업데이트
    if [[ -f "$CAELESTIA_CONFIG_DIR/NotifsConfig.qml" ]]; then
        echo "Notifications 설정 업데이트 중..."
        # Notifications 관련 색상 설정 업데이트 로직
    fi
}

# 8. caelestia-shell 재시작
restart_caelestia_shell() {
    echo "caelestia-shell 재시작 중..."
    
    if systemctl --user is-active --quiet caelestia-shell.service; then
        systemctl --user restart caelestia-shell.service
        echo "caelestia-shell이 재시작되었습니다."
    else
        echo "caelestia-shell 서비스가 실행 중이 아닙니다. 수동으로 시작하세요:"
        echo "  systemctl --user start caelestia-shell.service"
    fi
}

# 9. 테마 동기화 상태 저장
save_sync_state() {
    local sync_state_file="$HOME/.config/hyde/ui/last_sync"
    
    cat > "$sync_state_file" << EOF
# Hyde-Caelestia 마지막 동기화 정보
sync_date=$(date)
hyde_theme=$(get_current_hyde_theme)
primary_color=$HYDE_PRIMARY_COLOR
secondary_color=$HYDE_SECONDARY_COLOR
accent_color=$HYDE_ACCENT_COLOR
background_color=$HYDE_BACKGROUND_COLOR
foreground_color=$HYDE_FOREGROUND_COLOR
surface_color=$HYDE_SURFACE_COLOR
EOF
    
    echo "동기화 상태가 저장되었습니다: $sync_state_file"
}

# 메인 실행
main() {
    local theme_name="$1"
    
    echo "Hyde-Caelestia 테마 동기화를 시작합니다..."
    
    if [[ -n "$theme_name" ]]; then
        echo "지정된 테마: $theme_name"
    else
        echo "현재 Hyde 테마를 사용합니다."
    fi
    
    extract_hyde_theme "$theme_name"
    apply_caelestia_theme
    save_sync_state
    restart_caelestia_shell
    
    echo ""
    echo "=== 테마 동기화 완료 ==="
    echo ""
    echo "변경사항이 적용되었습니다. caelestia-shell이 새로운 테마로 실행됩니다."
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

