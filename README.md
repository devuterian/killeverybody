# KillEverybody

macOS에서 **메뉴바·에이전트 성격의 앱(주로 `LSUIElement`)과 시스템 필수 프로세스는 건너뛰고**, 선택한 범위 안의 나머지 프로세스를 **미리본 뒤 `kill -9`(SIGKILL)로 강제 종료**하는 SwiftUI **창 앱**입니다.

## 공개 저장소·바이너리

- **GitHub(소스):** [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- **릴리즈·DMG:** [Releases — v1.0.0](https://github.com/devuterian/killeverybody/releases/tag/v1.0.0)에서 **`KillEverybody-macOS.dmg`** 를 받을 수 있습니다. (GitHub Actions에서 서명 없이 빌드됩니다.)

이 저장소는 [LPFchan/repo-template](https://github.com/LPFchan/repo-template)의 scaffold(문서·스킬·선택적 커밋 검사)를 베이스로 포함합니다. 제품 동작의 요약은 [`SPEC.md`](SPEC.md)를 보세요.

## 경고(필독)

- **저장되지 않은 문서·작업은 즉시 사라질 수 있습니다.** 브라우저 탭, IDE, 오디오·영상 편집기 등이 대상에 들어가면 복구가 불가능할 수 있습니다.
- **시스템이 불안정해지거나 로그인 세션이 끊길 수 있습니다.** denylist로 위험한 프로세스를 줄이지만, **완전 보장은 불가능**합니다.
- **메뉴바 앱 판별은 완벽하지 않습니다.** `Info.plist`의 `LSUIElement`와 사용자가 지정한 **예외 번들 ID**에 의존합니다. 일부 메뉴바 앱은 일반 앱처럼 보일 수 있고, 그 반대도 있습니다.
- 이 소프트웨어는 **“있는 그대로” 제공**되며, 사용으로 인한 손해에 대해 개발자·기여자는 책임을 지지 않습니다. **본인 책임 하에** 사용하세요.

## 요구 사항

- macOS **13(Ventura)** 이상 권장  
- **Xcode**(SwiftUI 빌드; Command Line Tools만으로는 `xcodebuild`가 제한될 수 있음)

## 빌드 방법

1. 이 저장소를 클론합니다.
2. `KillEverybodyApp/KillEverybodyApp.xcodeproj`를 Xcode로 엽니다.
3. 스킴 **KillEverybodyApp**을 선택한 뒤 **Run(⌘R)** 으로 빌드·실행합니다.

로컬에서 코드 서명 없이 시험하려면 Xcode에서 **Signing & Capabilities**의 Team을 조정하거나, `xcodebuild` 사용 시 예시:

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

생성된 앱은 DerivedData 아래에 있습니다(경로는 Xcode 빌드 로그를 참고).

## 사용 방법

1. 왼쪽 패널에서 **종료 범위**를 고릅니다.
   - **GUI 앱만:** `NSWorkspace`에 올라온 앱만 대상. `LSUIElement` 번들은 제외.
   - **현재 사용자 프로세스 전체:** 현재 로그인 사용자 UID와 같은 프로세스. denylist·`LSUIElement`·예외 번들은 제외.
   - **관리자 권한(실험적):** 위와 **동일한 대상 목록**을 `osascript`의 `administrator privileges`로 `kill -9`합니다. **암호 입력 창**이 뜹니다.
2. **대상 수집**을 눌러 목록을 만듭니다.
3. 오른쪽 테이블에서 종료될 PID·이름·경로를 확인합니다.
4. **강제 종료 실행** → 확인 후 kill.

**예외 번들 ID**(톱니 아이콘): 종료에서 제외할 앱의 번들 식별자를 추가합니다(예: `com.apple.Safari`).

## 커밋 메시지·훅(선택)

템플릿에 포함된 검사를 쓰려면:

```bash
./scripts/install-hooks.sh
```

푸시 시 동일 규칙을 CI로 돌리려면 [`.github/workflows/commit-standards.yml`](.github/workflows/commit-standards.yml)가 있습니다. 부트스트랩 예외는 [scripts/check-commit-standards.sh](scripts/check-commit-standards.sh) 주석을 참고하세요.

## 포크·미러에 올리기

다른 계정으로 미러하려면 원격 URL만 바꿔 푸시하면 됩니다. (이미 공개 저장소가 있으면 위 Releases 링크를 쓰면 됩니다.)

## 라이선스

라이선스는 별도 파일이 없으면 기본적으로 **All Rights Reserved**로 간주될 수 있습니다. 오픈 소스로 공개하려면 `LICENSE` 파일을 추가하세요.
