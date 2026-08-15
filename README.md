<div align="center">

<img src="docs/readme-app-icon.png" width="220" alt="killeverybody 앱 아이콘" />

# killeverybody

### 맥에서 실행 중인 앱과 자식 프로세스를 한 번에 정리해요.

**한국어** | [English](README.en.md) | [日本語](README.ja.md)

현재 문서는 **v3.0.0** 기준입니다.

키플러님의 Windows용 [다죽여](http://kippler.com/allkill/)에서 영감을 받아 만들었어요.

</div>

---

## 먼저 알아둘 점

> **주의:** 이 앱은 대상 프로세스에 `SIGKILL`을 보냅니다. 저장하지 않은 작업은 사라질 수 있어요.

**다죽이기**와 **적당히 죽이기**는 버튼을 누르면 추가 확인 없이 바로 실행됩니다. 일부러 그렇게 만든 동작이에요. 처음에는 DMG에 함께 든 `killeverybody-cli`로 드라이런해 보는 걸 권합니다.

```bash
/Volumes/killeverybody/killeverybody-cli --dry-run
```

## 기능

| 기능 | 동작 |
| --- | --- |
| **다죽이기** | 실행 중인 앱과 그 자식 프로세스를 종료합니다. 고정 시스템 보호 목록과 killeverybody 자신만 남기며, 저장한 예외는 적용하지 않습니다. |
| **적당히 죽이기** | 같은 범위에서 사용자가 고른 예외 앱, 메뉴 막대 취급 앱, 내장 프리셋, `LSUIElement` 앱을 제외합니다. |
| **예외 앱…** | 아이콘이 있는 앱 목록을 이름·번들 ID·경로로 검색하고 체크합니다. `전체 앱`, `실행 중`, `로그인 시 실행` 필터도 있어요. |
| **자동 재실행 억제** | 종료 대상 앱과 연결된 서드파티 LaunchAgent를 현재 로그인 세션에서만 내립니다. 다음 로그인 때는 원래대로 돌아옵니다. |
| **자동 업데이트** | Sparkle이 GitHub Releases의 새 DMG를 확인하고 가능한 업데이트를 자동으로 내려받아 설치합니다. |

종료가 모두 성공하면 결과 창을 띄우지 않고 killeverybody도 정상 종료합니다. 실패한 항목이 있을 때만 결과와 관리자 권한 재시도 버튼을 보여 줍니다.

## 설치와 업데이트

요구 환경은 **macOS 13 Ventura 이상**입니다.

1. [최신 릴리즈](https://github.com/devuterian/killeverybody/releases/latest)에서 `KillEverybody-macOS.dmg`를 받아요.
2. DMG를 열고 `killeverybody.app`을 **응용 프로그램** 폴더에 옮겨요.
3. 앱을 실행하면 끝입니다.

GitHub Actions 배포판은 현재 **Apple 개발자 서명·공증이 없습니다**. macOS가 막으면 앱을 **우클릭 → 열기**로 한 번 실행하거나, **시스템 설정 → 개인 정보 보호 및 보안**에서 허용해 주세요.

앱을 켜면 Sparkle이 백그라운드에서 새 버전을 확인합니다. 직접 확인하려면 앱 메뉴의 **업데이트 확인…**, 브라우저에서 받으려면 **최신 릴리즈 열기…**를 누르면 돼요. 업데이트 DMG의 무결성은 Sparkle EdDSA 서명으로 확인합니다.

## 사용법

1. 앱을 켜면 macOS 기본 경고창 느낌의 **「다 죽일까요?」** 창이 나옵니다.
2. 정말 전부 정리하려면 **다죽이기**를 누릅니다.
3. 보호할 앱을 남기려면 먼저 **예외 앱…**에서 체크한 뒤 **적당히 죽이기**를 누릅니다.
4. 앱만 닫으려면 **종료**를 누르거나 `Esc`를 누릅니다.

### 적당히 죽이기에서 살아남을 앱

**예외 앱…**을 누르면 별도 설정 창이 열립니다.

- 설치된 앱과 실행 중인 앱을 아이콘과 함께 보여 줍니다.
- 앱 이름, 번들 ID, 경로로 검색할 수 있습니다.
- 첫 실행 때 macOS 로그인 앱을 기본 예외로 한 번만 체크합니다. 이 조회 때문에 관리자 암호를 묻지 않습니다.
- 체크를 바꾸면 바로 저장됩니다.
- **고급** 탭에서는 번들 ID를 직접 넣거나, 메뉴 막대 앱으로 취급할 번들을 추가할 수 있습니다.
- 현재 예외·메뉴 막대 정책을 JSON으로 내보내거나 다시 가져올 수 있습니다.

## CLI와 드라이런

DMG 안의 `killeverybody-cli`는 기본 동작이 드라이런입니다. 후보만 출력하며 신호를 보내지 않아요.

```bash
# 적당히 죽이기 후보
/Volumes/killeverybody/killeverybody-cli --dry-run

# 다죽이기 후보
/Volumes/killeverybody/killeverybody-cli --aggressive --dry-run

# JSON으로 보기
/Volumes/killeverybody/killeverybody-cli --dry-run --json

# 앱에서 내보낸 정책 JSON 적용
/Volumes/killeverybody/killeverybody-cli --policy ./killeverybody-policy.json --dry-run
```

CLI는 앱의 저장 설정을 자동으로 읽지 않습니다. 같은 예외를 쓰려면 앱에서 정책 JSON을 내보내 `--policy`로 지정하세요. 실제 종료는 `--execute --yes`를 함께 넣어야만 작동합니다.

## 동작 범위와 한계

- 대상은 **현재 사용자 계정에서 실행 중인 앱과 그 자식 프로세스**입니다. 같은 UID라는 이유만으로 셸이나 모든 백그라운드 프로세스를 죽이지는 않습니다.
- 시스템 핵심 프로세스와 killeverybody 자신은 고정 보호 목록에서 제외합니다.
- 앱 헬퍼는 가장 바깥쪽 앱 번들에 묶어서 예외를 판단합니다.
- 자동 재실행 억제는 `~/Library/LaunchAgents`와 `/Library/LaunchAgents`의 일치하는 서드파티 항목을 현재 GUI 세션에서만 내립니다. plist와 로그인 항목은 수정하지 않습니다.
- 메뉴 막대 앱 판별은 공개 API 기반 휴리스틱이라 완벽하지 않습니다.
- Finder처럼 macOS가 직접 관리하는 앱은 다시 켜질 수 있습니다.
- 데이터 보존이나 시스템 안정성을 보장하지 않습니다. 중요한 작업은 먼저 저장하세요.

## 빌드

Xcode에서 `KillEverybodyApp/KillEverybodyApp.xcodeproj`를 열고 **KillEverybodyApp** 스킴을 실행하세요. 명령줄 빌드는 다음과 같습니다.

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

CLI는 **KillEverybodyCLI** 스킴으로 빌드할 수 있습니다. 더 자세한 내용은 [`docs/build.md`](docs/build.md)를 봐 주세요.

## 소스와 기여

- 저장소: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- 기여와 Sparkle 설정: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- 수동 점검: [`docs/smoke-test.md`](docs/smoke-test.md)
- 동작 명세: [`SPEC.md`](SPEC.md)
- 버그와 질문: [Issues](https://github.com/devuterian/killeverybody/issues)

## 라이선스

[MIT License](LICENSE)입니다. 위험한 도구인 만큼 면책 조항도 꼭 확인해 주세요.

---

<div align="center">

저장소 운영·문서 골격은 [LPFchan/repo-template](https://github.com/LPFchan/repo-template)을 참고했어요.<br>
템플릿을 공개해 주셔서 고맙습니다.

</div>
