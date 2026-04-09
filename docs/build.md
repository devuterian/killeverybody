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

산출물은 `…/Build/Products/Debug/killeverybody.app` (또는 Release)입니다. 로그의 `BUILD_DIR` / DerivedData를 참고하세요.

## 타입 검사만 (Xcode 없이 시도)

```bash
./scripts/smoke-check.sh
```

전체 Xcode가 없으면 여기서도 실패할 수 있습니다.

## README 히어로 아이콘

GitHub는 README 안의 `<img>`에 **CSS `style`(border-radius 등)을 적용하지 않습니다.** 상단 둥근 아이콘은 미리 마스크한 PNG(`docs/readme-app-icon.png`)를 씁니다.

마스크는 **SwiftUI `RoundedRectangle(..., style: .continuous)`** 와 같은 연속 곡률 베지어(맥·iOS 앱 아이콘 크롬과 동일 계열, macOS 26 포함)입니다. 단순 `rounded_rectangle`이 아닙니다.

앱 아이콘 에셋을 바꾼 뒤 아래를 한 번 실행하세요 (Pillow 필요: `pip install pillow`).

```bash
python3 scripts/generate-readme-icon.py
```
