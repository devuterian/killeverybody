# 빌드·실행 (개발자)

## 요구 사항

- macOS 13(Ventura) 이상 권장
- **Xcode** (SwiftUI 앱은 `xcodebuild`에 전체 Xcode가 필요한 경우가 많음)

## Xcode에서

1. 저장소를 클론합니다.
2. `KillEverybodyApp/KillEverybodyApp.xcodeproj`를 엽니다.
3. 스킴 **KillEverybodyApp** → **Run (⌘R)**.

## 명령줄 (서명 끔)

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

산출물 경로는 로그의 `BUILD_DIR` / DerivedData를 참고하세요.

## 타입 검사만 (Xcode 없이 시도)

```bash
./scripts/smoke-check.sh
```

전체 Xcode가 없으면 여기서도 실패할 수 있습니다.
