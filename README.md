# KillEverybody

맥에서 돌아가는 앱·프로그램을 **목록으로 보여 준 뒤**, 골라 **강제로 끄는** 도구예요. 메뉴 막대에만 붙어 있는 앱이나, 맥이 돌아가게 필요한 일부 프로그램은 **가능하면 건너뜁니다.**

---

## 먼저 받기

1. **[Releases에서 최신 DMG](https://github.com/devuterian/killeverybody/releases)** 를 받아요. (`KillEverybody-macOS.dmg`)
2. DMG를 열고, **KillEverybody.app**을 **응용 프로그램** 폴더로 옮겨요.
3. 앱을 실행해요.

**막히면:** 처음엔 **보안 경고**가 뜰 수 있어요. DMG는 GitHub에서 자동 빌드·올린 거라 **개발자 서명·공증이 없을 수** 있어요. 앱을 **우클릭 → 열기**로 한 번 열거나, **시스템 설정 → 개인 정보 보호 및 보안**에서 허용을 확인해 보세요.

---

## 이 앱이 하는 일

- 실행 범위를 고른 다음, **대상 수집**으로 끌 후보를 모아 표로 보여 줘요.
- **강제 종료 실행**을 누르면, 확인 창 뒤에 선택한 프로세스를 **강제로 종료**해요.

## 이 앱이 못 맞추는 것

- 메뉴 막대 앱을 **항상** 정확히 구분하진 못해요. 앱마다 설정이 달라서 그래요. 빼고 싶은 앱이 있으면 **설정(톱니)** 에서 **예외 번들 ID**를 넣어 주세요.
- 맥을 안전하게 만든다고 **보장하지는 않아요.** 그래도 중요한 프로그램 이름은 목록에서 빼 두려고 해요.

---

## 쓰기 전에

저장 안 한 문서·편집 중인 파일·켜 둔 앱은 **그대로 잃을 수 있어요.** 한 번 목록을 꼭 보고, 괜찮을 때만 진행하는 걸 추천해요.

버그나 질문은 [Issues](https://github.com/devuterian/killeverybody/issues)로 남겨 주세요.

---

## 앱 안에서 이렇게 써요

1. 왼쪽에서 **종료 범위**를 고릅니다.
   - **GUI 앱만** — 화면에 올라온 앱 위주. 메뉴 막대만 쓰는 앱 성격은 가급적 제외.
   - **현재 사용자 프로세스 전체** — 지금 로그인한 사용자 기준으로 더 넓게. 역시 위험한 이름·메뉴 막대 쪽·예외 목록은 빼요.
   - **관리자 권한(실험적)** — 위와 **같은 목록**인데, 맥 비밀번호 창이 뜰 수 있어요. 특별히 필요할 때만 써 보세요.
2. **대상 수집**을 누릅니다.
3. 오른쪽 표에서 이름과 경로를 확인합니다.
4. **강제 종료 실행** → 확인 후 진행합니다.

**예외 번들 ID:** 톱니 아이콘에서, 끄지 않을 앱의 번들 ID를 넣을 수 있어요. (예: Safari를 빼고 싶다면 `com.apple.Safari`)

---

## 소스 코드

저장소: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)

### 맞는 맥

- macOS 13(Ventura) 이상을 권장해요.
- 소스에서 빌드하려면 **Xcode**가 있어야 해요.

### 빌드하기

1. 저장소를 클론해요.
2. `KillEverybodyApp/KillEverybodyApp.xcodeproj`를 Xcode로 열어요.
3. 위쪽 스킴에서 **KillEverybodyApp**을 고르고 **Run(⌘R)** 을 눌러요.

서명 없이 명령줄로만 빌드할 때 예시는 아래예요.

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

빌드된 앱 위치는 Xcode 로그나 DerivedData 안을 보면 돼요.

### 이 저장소 구조

이 프로젝트는 [LPFchan/repo-template](https://github.com/LPFchan/repo-template) 틀(문서·스킬 등)을 같이 쓰고 있어요. 동작 요약은 [`SPEC.md`](SPEC.md)를 보면 돼요.

로컬에서 커밋 규칙 훅을 쓰려면:

```bash
./scripts/install-hooks.sh
```

CI는 [`.github/workflows/commit-standards.yml`](.github/workflows/commit-standards.yml) 를 보면 돼요.

---

## 라이선스

`LICENSE` 파일이 없으면, 법적으로는 **권리가 모두 작성자에게 있다**고 보는 경우가 많아요. 오픈 소스로 쓰고 싶다면 라이선스 파일을 추가하는 걸 권장해요.

---

글 표현은 [토스의 8가지 라이팅 원칙](https://toss.tech/article/8-writing-principles-of-toss)을 참고해 짧고 읽기 쉽게 맞췄어요.
