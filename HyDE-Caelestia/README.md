# Hyde-Caelestia: Modern Desktop Environment

<div align="center">

![Hyde-Caelestia Logo](https://via.placeholder.com/400x200/6366f1/ffffff?text=Hyde-Caelestia)

**Hyde의 강력한 백엔드 + Caelestia-shell의 현대적 UI**

[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Hyprland](https://img.shields.io/badge/Hyprland-Compatible-green.svg)](https://hyprland.org)
[![Qt6](https://img.shields.io/badge/Qt6-QML-orange.svg)](https://qt.io)

</div>

## 🌟 개요

Hyde-Caelestia는 [HyDE 프로젝트](https://github.com/HyDE-Project/HyDE)의 안정적이고 강력한 백엔드 시스템에 [caelestia-shell](https://github.com/caelestia-dots/shell)의 현대적이고 세련된 UI를 통합한 혁신적인 데스크톱 환경입니다.

### ✨ 주요 특징

- **🎨 현대적 UI**: Material Design 3 기반의 세련된 인터페이스
- **🔧 강력한 백엔드**: Hyde의 검증된 설치 및 관리 시스템
- **🎯 통합 경험**: 일관된 디자인 언어와 사용자 경험
- **⚡ 고성능**: QML 기반의 효율적인 UI 렌더링
- **🔄 자동 동기화**: Hyde 테마 변경 시 UI 자동 적용

## 🏗️ 아키텍처

### UI 컴포넌트 매핑

| 기존 Hyde UI | Hyde-Caelestia | 기능 |
|-------------|----------------|------|
| Waybar | caelestia-shell Bar | 상태 바, 시스템 정보 |
| Rofi | caelestia-shell Launcher | 애플리케이션 런처 |
| Dunst | caelestia-shell Notifications | 알림 시스템 |
| - | caelestia-shell Dashboard | 시스템 대시보드 (신규) |

### 기술 스택

- **윈도우 매니저**: Hyprland
- **UI 프레임워크**: Quickshell (QML)
- **디자인 시스템**: Material Design 3
- **백엔드**: Hyde 설치 및 관리 시스템

## 📦 설치

### 시스템 요구사항

- **OS**: Arch Linux (권장) 또는 Arch 기반 배포판
- **DE/WM**: Hyprland
- **패키지 매니저**: pacman + AUR 헬퍼 (yay, paru 등)

### 자동 설치 (권장)

```bash
# 저장소 클론
git clone https://github.com/your-username/Hyde-Caelestia.git
cd Hyde-Caelestia

# 전체 설치 (Hyde + caelestia-shell 통합)
./Scripts/install.sh -i -r

# 시스템 재부팅 (권장)
sudo reboot
```

### 수동 설치

```bash
# 1. 의존성 설치
./Scripts/integration/install_caelestia_deps.sh

# 2. caelestia-shell 설정
./Scripts/integration/setup_caelestia.sh

# 3. 테마 동기화
./Scripts/integration/theme_bridge.sh
```

### 기존 Hyde 사용자 마이그레이션

```bash
# 기존 Hyde 설치에서 caelestia-shell로 마이그레이션
./Scripts/integration/ui_migration.sh
```

## 🚀 사용법

### 기본 조작

- **Super + Space**: 애플리케이션 런처 열기
- **Super + D**: 대시보드 토글
- **Super + N**: 알림 센터 열기
- **Super + L**: 화면 잠금
- **Super + Q**: 세션 메뉴

### 테마 변경

```bash
# Hyde 테마 변경 후 caelestia-shell 동기화
./Scripts/integration/theme_bridge.sh [테마명]

# 또는 Hyde 테마 패처 사용 (자동 동기화)
./Scripts/themepatcher.sh
```

### 설정 관리

```bash
# 설정 백업
./Scripts/restore_cfg.sh -b

# 설정 복원
./Scripts/restore_cfg.sh -r
```

## 🎨 커스터마이징

### UI 설정 파일 위치

```
~/.config/quickshell/caelestia/
├── config/                 # 설정 파일들
│   ├── Appearance.qml      # 외관 설정
│   ├── BarConfig.qml       # 바 설정
│   ├── LauncherConfig.qml  # 런처 설정
│   └── ...
├── modules/                # UI 모듈들
└── services/               # 시스템 서비스 연동
```

### 색상 커스터마이징

`~/.config/quickshell/caelestia/config/Appearance.qml` 파일을 편집하여 색상을 변경할 수 있습니다:

```qml
QtObject {
    property color primaryColor: "#6366f1"      // 주 색상
    property color secondaryColor: "#8b5cf6"    // 보조 색상
    property color accentColor: "#06b6d4"       // 강조 색상
    property color backgroundColor: "#0f172a"   // 배경 색상
    // ...
}
```

## 🔧 문제 해결

### 일반적인 문제들

#### caelestia-shell이 시작되지 않는 경우

```bash
# 서비스 상태 확인
systemctl --user status caelestia-shell.service

# 수동 시작
systemctl --user start caelestia-shell.service

# 로그 확인
journalctl --user -u caelestia-shell.service -f
```

#### 테마가 적용되지 않는 경우

```bash
# 테마 동기화 재실행
./Scripts/integration/theme_bridge.sh

# caelestia-shell 재시작
systemctl --user restart caelestia-shell.service
```

#### 기존 UI로 롤백

```bash
# caelestia-shell 중지
systemctl --user stop caelestia-shell.service
systemctl --user disable caelestia-shell.service

# 백업된 설정 복원 (마이그레이션 시 생성된 백업 디렉토리 사용)
cp -r ~/.config/hyde/backup/ui_migration_*/waybar ~/.config/
cp -r ~/.config/hyde/backup/ui_migration_*/rofi ~/.config/
cp -r ~/.config/hyde/backup/ui_migration_*/dunst ~/.config/

# 기존 서비스 재시작
systemctl --user start waybar.service
dunst &
```

## 📁 프로젝트 구조

```
Hyde-Caelestia/
├── Configs/                # Hyde 설정 파일들
├── Scripts/                # 설치 및 관리 스크립트들
│   └── integration/        # 통합 관련 스크립트들
├── Source/                 # Hyde 리소스 파일들
├── Shell/                  # caelestia-shell 소스 코드
└── README.md              # 이 파일
```

## 🤝 기여하기

1. 이 저장소를 포크합니다
2. 기능 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

## 📄 라이선스

이 프로젝트는 GPL-3.0 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🙏 감사의 말

- **[HyDE Project](https://github.com/HyDE-Project/HyDE)**: 강력한 백엔드 시스템 제공
- **[caelestia-dots](https://github.com/caelestia-dots)**: 아름다운 UI 컴포넌트 제공
- **[Hyprland](https://hyprland.org)**: 현대적인 Wayland 컴포지터
- **[Quickshell](https://quickshell.outfoxxed.me)**: QML 기반 셸 프레임워크

## 📞 지원

- **이슈 리포트**: [GitHub Issues](https://github.com/your-username/Hyde-Caelestia/issues)
- **토론**: [GitHub Discussions](https://github.com/your-username/Hyde-Caelestia/discussions)
- **문서**: [Wiki](https://github.com/your-username/Hyde-Caelestia/wiki)

---

<div align="center">

**Hyde-Caelestia로 더 나은 데스크톱 경험을 만나보세요! 🚀**

</div>

