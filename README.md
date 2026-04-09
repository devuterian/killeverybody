# KillEverybody

맥에서 실행 중인 앱·프로그램을 **목록으로 보여 준 뒤**, 원하는 걸 골라 **강제로 종료**할 수 있는 도구예요. 메뉴 막대 전용 앱이나 맥 시스템에 꼭 필요한 프로세스는 **가급적 건너뜁니다.**

---

## 설치하기

1. **[Releases에서 최신 DMG](https://github.com/devuterian/killeverybody/releases)** 를 받아요. (`KillEverybody-macOS.dmg`)
2. DMG를 열고, **KillEverybody.app**을 **응용 프로그램** 폴더에 끌어다 놓아요.
3. 앱을 실행하면 끝이에요.

**보안 경고가 뜨면:** GitHub Actions로 자동 빌드한 앱이라 **개발자 서명·공증이 없을 수** 있어요. **우클릭 → 열기**로 한 번만 실행하거나, **시스템 설정 → 개인 정보 보호 및 보안**에서 허용해 주면 돼요.

---

## 이런 걸 해줘요

- 범위를 고른 뒤 **대상 수집**을 누르면, 끌 수 있는 프로세스를 표로 쭉 보여줘요.
- **강제 종료 실행**을 누르면 확인 창이 한 번 뜨고, 선택한 프로세스를 모두 종료해요.

## 이런 건 못해요

- 메뉴 막대 앱을 **항상** 정확하게 걸러내진 못해요. 앱마다 구현 방식이 달라서 그래요. 특정 앱을 빼고 싶으면 **설정(톱니바퀴)** 에서 **예외 번들 ID**를 직접 추가해 주세요.
- 맥을 안전하게 유지해 준다고 **보장하지는 않아요.** 다만 시스템에서 중요한 프로세스 이름은 미리 목록에서 제외해 뒀어요.

---

## 쓰기 전에 꼭 읽어 주세요

저장 안 한 문서나 작업 중인 파일은 **그대로 날아갈 수 있어요.** 반드시 목록을 먼저 확인하고, 괜찮을 때만 진행해 주세요.

버그나 질문은 [Issues](https://github.com/devuterian/killeverybody/issues)에 남겨 주세요.

---

## 사용 방법

1. 왼쪽에서 **종료 범위**를 골라요.
   - **GUI 앱만** — 화면에 띄워진 앱 위주로 수집해요. 메뉴 막대 전용 앱은 가급적 빼요.
   - **현재 사용자 프로세스 전체** — 로그인한 사용자의 프로세스를 더 넓게 수집해요. 위험한 이름이나 메뉴 막대 앱, 예외 목록은 마찬가지로 제외돼요.
   - **관리자 권한 (실험적)** — 위와 같은 범위인데, 실행 시 맥 비밀번호를 요구할 수 있어요. 꼭 필요할 때만 써 보세요.
2. **대상 수집**을 눌러요.
3. 오른쪽 표에서 이름과 경로를 쭉 확인해요.
4. **강제 종료 실행** → 확인하고 진행해요.

**예외 번들 ID:** 톱니바퀴 아이콘을 눌러 종료에서 제외할 앱의 번들 ID를 추가할 수 있어요. (예: Safari를 빼고 싶다면 `com.apple.Safari`)

---

## 소스 코드

저장소: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)

### 지원 환경

- **macOS 13 (Ventura) 이상**을 권장해요.
- 소스에서 직접 빌드하려면 **Xcode**가 필요해요.

### 빌드하기

1. 저장소를 클론해요.
2. `KillEverybodyApp/KillEverybodyApp.xcodeproj`를 Xcode로 열어요.
3. 상단 스킴에서 **KillEverybodyApp**을 선택하고 **Run(⌘R)** 을 눌러요.

서명 없이 커맨드라인으로만 빌드하고 싶다면 이렇게 하면 돼요.

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

빌드된 앱 위치는 Xcode 로그나 DerivedData 폴더에서 확인할 수 있어요.

### 저장소 구조

이 프로젝트는 [LPFchan/repo-template](https://github.com/LPFchan/repo-template) 템플릿(문서·스킬 등)을 함께 사용하고 있어요. 동작 상세는 [`SPEC.md`](SPEC.md)를 참고해 주세요.

로컬에서 커밋 규칙 훅을 설정하려면 아래를 실행해요.

```bash
./scripts/install-hooks.sh
```

CI 설정은 [`.github/workflows/commit-standards.yml`](.github/workflows/commit-standards.yml)에 있어요.

---

## 라이선스

`LICENSE` 파일이 없으면, 법적으로 **모든 권리가 작성자에게 있는 것**으로 보는 경우가 많아요. 오픈 소스로 공개하고 싶다면 라이선스 파일을 추가하는 걸 추천해요.

---

글 표현은 [토스의 8가지 라이팅 원칙](https://toss.tech/article/8-writing-principles-of-toss)을 참고해 짧고 읽기 쉽게 맞췄어요.
