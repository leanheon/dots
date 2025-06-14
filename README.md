# HyDE-Caelestia: UI 대체 통합 프로젝트

## 프로젝트 개요

HyDE-Caelestia는 HyDE 프로젝트의 UI 요소를 Caelestia-dots/shell의 현대적인 QML 기반 UI 컴포넌트로 완전히 대체한 통합 데스크톱 환경입니다. 이 프로젝트는 HyDE의 안정적이고 완성도 높은 백엔드 시스템을 유지하면서, Caelestia-shell의 세련되고 현대적인 사용자 인터페이스를 제공합니다.

### 주요 특징

- **완전한 UI 대체**: HyDE의 Waybar, Rofi, Dunst를 Caelestia-shell의 Bar, Launcher, Notifications로 대체
- **자동화된 통합**: HyDE의 기존 설치 시스템에 완전히 통합된 자동 UI 대체 프로세스
- **테마 시스템 연동**: HyDE 테마와 Caelestia-shell UI의 자동 동기화
- **호환성 유지**: 기존 HyDE 사용자의 워크플로우와 설정 완전 보존

### 기술 스택

- **백엔드**: HyDE (Hyprland 기반 데스크톱 환경)
- **UI 프레임워크**: Quickshell (QML 기반)
- **UI 컴포넌트**: Caelestia-shell
- **테마 시스템**: Material Design 3 + HyDE 테마 연동
- **서비스 관리**: Systemd

## 설치 가이드

### 시스템 요구사항

- **운영체제**: Arch Linux (또는 Arch 기반 배포판)
- **디스플레이 서버**: Wayland
- **윈도우 매니저**: Hyprland
- **패키지 관리자**: pacman + AUR 헬퍼 (paru 또는 yay)

### 의존성 패키지

HyDE-Caelestia는 다음 패키지들을 자동으로 설치합니다:

#### 핵심 의존성
```bash
# Quickshell 및 Qt6 의존성
quickshell-git          # QML 기반 셸 프레임워크
qt6-declarative         # Qt6 QML 모듈
qt6-wayland            # Qt6 Wayland 지원
qt6-svg                # Qt6 SVG 지원
qt6-multimedia         # Qt6 멀티미디어 지원

# 시스템 의존성
hyprland               # Wayland 컴포지터
systemd                # 서비스 관리
```

#### 선택적 의존성
```bash
# 개발 도구 (선택사항)
qt6-tools              # Qt6 개발 도구
qt6-doc                # Qt6 문서

# 추가 기능
cava                   # 오디오 시각화
ttf-material-design-icons-desktop-git  # Material Design 아이콘
```

### 설치 과정

#### 1. 저장소 클론
```bash
git clone https://github.com/your-username/HyDE-Caelestia.git ~/HyDE-Caelestia
cd ~/HyDE-Caelestia/Scripts
```

#### 2. 설치 실행
```bash
# 기본 설치 (권장)
./install.sh

# 기본값으로 자동 설치
./install.sh -d

# 설정만 복원 (이미 설치된 경우)
./install.sh -r
```

#### 3. 설치 과정 세부사항

설치 스크립트는 다음 단계를 자동으로 수행합니다:

1. **패키지 설치**: HyDE 핵심 패키지 + Caelestia-shell 의존성
2. **설정 복원**: HyDE 설정 파일 복원
3. **UI 대체**: 기존 UI 컴포넌트 제거 및 Caelestia-shell 설정
4. **서비스 설정**: Systemd 서비스 생성 및 활성화
5. **테마 연동**: 테마 동기화 도구 설치

#### 4. 설치 완료 후
```bash
# 시스템 재부팅 (권장)
sudo reboot

# 또는 수동으로 Caelestia-shell 시작
systemctl --user start caelestia-shell.service
```

### 설치 문제 해결

#### AUR 헬퍼가 없는 경우
```bash
# paru 설치
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# 또는 yay 설치
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

#### Quickshell 수동 설치
```bash
git clone https://aur.archlinux.org/quickshell-git.git
cd quickshell-git
makepkg -si
```

## 활용 가이드

### 기본 사용법

#### Caelestia-shell 서비스 관리
```bash
# 서비스 상태 확인
systemctl --user status caelestia-shell.service

# 서비스 시작
systemctl --user start caelestia-shell.service

# 서비스 중지
systemctl --user stop caelestia-shell.service

# 서비스 재시작
systemctl --user restart caelestia-shell.service

# 자동 시작 활성화/비활성화
systemctl --user enable caelestia-shell.service
systemctl --user disable caelestia-shell.service
```

#### 수동 실행
```bash
# Caelestia-shell 직접 실행
quickshell -c caelestia

# 디버그 모드로 실행
quickshell -c caelestia --debug
```

### UI 컴포넌트 활용

#### 1. Bar (상태 바)
- **위치**: 화면 왼쪽 세로 바
- **기능**: 
  - 워크스페이스 표시 및 전환
  - 시스템 상태 (CPU, 메모리, 네트워크)
  - 시간 및 날짜
  - 시스템 트레이

#### 2. Dashboard (대시보드)
- **활성화**: Super + D 또는 바에서 대시보드 버튼 클릭
- **기능**:
  - 시스템 정보 표시
  - 미디어 컨트롤 (MPRIS)
  - 빠른 설정 토글
  - 사용자 프로필 정보

#### 3. Launcher (런처)
- **활성화**: Super + Space 또는 바에서 런처 버튼 클릭
- **기능**:
  - 애플리케이션 검색 및 실행
  - 파일 검색
  - 계산기 기능
  - 웹 검색

#### 4. Notifications (알림)
- **위치**: 화면 우상단
- **기능**:
  - 시스템 알림 표시
  - 알림 히스토리
  - 알림 액션 버튼
  - Do Not Disturb 모드

### 테마 시스템

#### 테마 동기화 도구 사용
```bash
# 현재 HyDE 테마를 Caelestia-shell에 적용
hyde-caelestia-theme-sync apply

# 특정 테마 적용
hyde-caelestia-theme-sync apply mocha

# 사용 가능한 테마 목록 보기
hyde-caelestia-theme-sync list

# 현재 테마 색상 정보 추출
hyde-caelestia-theme-sync extract
```

#### 수동 테마 설정
```bash
# 테마 브리지 스크립트 직접 실행
~/HyDE-Caelestia/Integration/theme-bridge.sh apply

# 색상 정보 확인
~/HyDE-Caelestia/Integration/theme-bridge.sh extract current
```

### 키보드 단축키

HyDE-Caelestia는 HyDE의 기존 키보드 단축키를 모두 지원하며, 추가로 다음 단축키를 제공합니다:

#### UI 컴포넌트 제어
```
Super + D              # Dashboard 토글
Super + Space          # Launcher 열기
Super + N              # 알림 센터 토글
Super + Shift + N      # Do Not Disturb 토글
```

#### 미디어 제어
```
XF86AudioPlay          # 재생/일시정지
XF86AudioNext          # 다음 트랙
XF86AudioPrev          # 이전 트랙
XF86AudioStop          # 정지
```

#### 시스템 제어
```
Super + L              # 화면 잠금
Super + Shift + E      # 로그아웃 메뉴
Super + Shift + R      # Caelestia-shell 재시작
```

### 설정 커스터마이징

#### Caelestia-shell 설정 위치
```
~/.config/quickshell/caelestia/
├── shell.qml          # 메인 설정 파일
├── config/            # 설정 파일들
├── modules/           # UI 모듈들
├── services/          # 시스템 서비스 연동
└── themes/            # 테마 파일들
```

#### 주요 설정 파일
```bash
# 외관 설정
~/.config/quickshell/caelestia/config/Appearance.qml

# 바 설정
~/.config/quickshell/caelestia/modules/bar/Bar.qml

# 대시보드 설정
~/.config/quickshell/caelestia/modules/dashboard/Dashboard.qml

# 런처 설정
~/.config/quickshell/caelestia/modules/launcher/Launcher.qml
```

#### 설정 수정 후 적용
```bash
# Caelestia-shell 재시작
systemctl --user restart caelestia-shell.service

# 또는 Hyprland 재시작
hyprctl reload
```

### 고급 활용

#### 1. 커스텀 위젯 추가
```qml
// ~/.config/quickshell/caelestia/widgets/CustomWidget.qml
import Quickshell
import QtQuick

Rectangle {
    width: 100
    height: 50
    color: "blue"
    
    Text {
        anchors.centerIn: parent
        text: "Custom Widget"
        color: "white"
    }
}
```

#### 2. 서비스 연동
```javascript
// JavaScript를 통한 시스템 서비스 연동
const service = new SystemService("my-service");
service.start();
```

#### 3. 테마 커스터마이징
```qml
// ~/.config/quickshell/caelestia/themes/CustomColors.qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property color primary: "#6366f1"
    readonly property color background: "#1e1e2e"
    readonly property color text: "#cdd6f4"
}
```

### 문제 해결

#### 일반적인 문제

##### 1. Caelestia-shell이 시작되지 않는 경우
```bash
# 로그 확인
journalctl --user -u caelestia-shell.service -f

# 의존성 확인
pacman -Q quickshell-git qt6-declarative qt6-wayland

# 수동 실행으로 오류 확인
quickshell -c caelestia
```

##### 2. 테마가 적용되지 않는 경우
```bash
# 테마 파일 확인
ls -la ~/.config/quickshell/caelestia/themes/

# 테마 동기화 재실행
hyde-caelestia-theme-sync apply

# Caelestia-shell 재시작
systemctl --user restart caelestia-shell.service
```

##### 3. UI 컴포넌트가 표시되지 않는 경우
```bash
# Hyprland 설정 확인
grep "quickshell" ~/.config/hypr/hyprland.conf

# 프로세스 확인
ps aux | grep quickshell

# 설정 파일 권한 확인
ls -la ~/.config/quickshell/caelestia/
```

#### 로그 및 디버깅

##### 시스템 로그 확인
```bash
# Caelestia-shell 서비스 로그
journalctl --user -u caelestia-shell.service

# Hyprland 로그
journalctl --user -u hyprland.service

# 시스템 로그
journalctl -xe
```

##### 디버그 모드 실행
```bash
# 상세 로그와 함께 실행
QT_LOGGING_RULES="*=true" quickshell -c caelestia

# 특정 카테고리 로그만 표시
QT_LOGGING_RULES="quickshell.*=true" quickshell -c caelestia
```

### 업데이트 및 유지보수

#### 프로젝트 업데이트
```bash
cd ~/HyDE-Caelestia
git pull origin main

# 설정 업데이트
./Scripts/install.sh -r
```

#### 백업 및 복원
```bash
# 설정 백업
cp -r ~/.config/quickshell/caelestia ~/.config/quickshell/caelestia.backup

# 설정 복원
cp -r ~/.config/quickshell/caelestia.backup ~/.config/quickshell/caelestia
```

#### 제거
```bash
# Caelestia-shell 서비스 중지 및 비활성화
systemctl --user stop caelestia-shell.service
systemctl --user disable caelestia-shell.service

# 설정 파일 제거
rm -rf ~/.config/quickshell/caelestia
rm ~/.config/systemd/user/caelestia-shell.service

# 패키지 제거 (선택사항)
paru -R quickshell-git qt6-declarative qt6-wayland qt6-svg qt6-multimedia
```

## 기여 및 지원

### 버그 리포트
- GitHub Issues를 통해 버그를 리포트해 주세요
- 로그 파일과 시스템 정보를 포함해 주세요

### 기능 요청
- GitHub Discussions에서 새로운 기능을 제안해 주세요
- 커뮤니티 투표를 통해 우선순위를 결정합니다

### 개발 참여
- Fork 후 Pull Request를 통해 기여해 주세요
- 코드 스타일 가이드를 준수해 주세요

### 라이선스
이 프로젝트는 GPL-3.0 라이선스 하에 배포됩니다.

---

HyDE-Caelestia는 HyDE의 안정성과 Caelestia-shell의 현대적인 UI를 결합하여 최고의 Linux 데스크톱 경험을 제공합니다.

