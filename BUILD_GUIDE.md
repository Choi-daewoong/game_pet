# 🎮 Petite Friends - 빌드 및 테스트 가이드

## 📱 APK 다운로드 및 설치

### GitHub Actions에서 APK 다운로드

1. GitHub 저장소로 이동
2. **Actions** 탭 클릭
3. 가장 최근 "Build Flutter APK" 워크플로우 실행 클릭
4. 페이지 하단 **Artifacts** 섹션에서 `petite-friends-release` 클릭하여 다운로드
5. ZIP 파일 압축 해제 → `app-release.apk` 파일 확인

### 안드로이드 기기에 설치

1. APK 파일을 핸드폰으로 전송 (USB, 이메일, 클라우드 등)
2. 핸드폰 **설정** → **보안** → **알 수 없는 출처** 허용
3. 파일 관리자에서 APK 파일 찾아서 실행
4. 설치 진행

## 🌐 웹 프리뷰

### 방법 1: Artifacts 다운로드 (로컬 실행)

1. GitHub 저장소 → **Actions** 탭
2. "Build Web Preview" 워크플로우 실행 찾기
3. **Artifacts** 섹션에서 `web-build` 다운로드
4. ZIP 압축 해제
5. `index.html` 파일을 Chrome/Edge 등의 브라우저에서 열기

### 방법 2: Vercel 무료 배포 (실제 URL)

1. https://vercel.com 접속 및 가입 (GitHub 계정으로 로그인)
2. "New Project" 클릭
3. GitHub 저장소 연동 및 선택
4. 프로젝트 설정:
   - Framework Preset: **Other**
   - Root Directory: `./`
   - Build Command: 자동 감지 (`vercel.json` 사용)
5. "Deploy" 클릭
6. 배포 완료 후 제공되는 URL로 접속

**주의:** Vercel은 무료 플랜에서도 private 저장소 지원하므로 비용 없이 사용 가능합니다.

## 🔧 수동 빌드 (로컬 환경)

### 사전 요구사항

- Flutter SDK 3.24.0 이상
- Android Studio (APK 빌드용)
- Java 17 (APK 빌드용)

### APK 빌드

```bash
cd petite_friends
flutter pub get
flutter build apk --release
```

빌드된 APK 위치: `petite_friends/build/app/outputs/flutter-apk/app-release.apk`

### 웹 빌드

```bash
cd petite_friends
flutter pub get
flutter build web --release
```

빌드된 웹 파일 위치: `petite_friends/build/web/`

## 📊 빌드 상태 확인

GitHub 저장소의 **Actions** 탭에서 실시간으로 빌드 진행 상황 확인 가능:

- ✅ 초록색 체크: 빌드 성공
- 🔄 노란색 점: 빌드 진행 중
- ❌ 빨간색 X: 빌드 실패

## 🎯 자동 빌드 트리거

다음 상황에서 자동으로 빌드가 실행됩니다:

1. `claude/review-pet-widget-game-01UBJTbD56z2133PKiS9vMt7` 브랜치에 푸시할 때
2. GitHub Actions의 "Run workflow" 버튼을 수동으로 클릭할 때

## 🐛 문제 해결

### APK 설치 안 됨
- "알 수 없는 출처" 설정 확인
- 이전 버전이 설치되어 있다면 먼저 삭제

### 웹 프리뷰가 제대로 작동 안 됨
- 최신 브라우저 사용 (Chrome, Edge, Firefox)
- 일부 기능은 웹에서 제한될 수 있음 (위젯, 백그라운드 작업 등)

### 빌드 실패
- GitHub Actions의 로그 확인
- 에러 메시지를 분석하여 원인 파악
