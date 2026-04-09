# 기여하기

## 저장소 구조

- 앱 소스: `KillEverybodyApp/KillEverybodyApp/`
- 제품·운영 문서: `SPEC.md`, `STATUS.md`, `PLANS.md`, `REPO.md`
- 이 저장소는 [LPFchan/repo-template](https://github.com/LPFchan/repo-template) 스캐폴드를 포함합니다.

## 빌드

[`docs/build.md`](docs/build.md)를 보세요.

## 커밋 메시지·훅

로컬에서 메시지 검사 훅을 쓰려면:

```bash
./scripts/install-hooks.sh
```

규칙은 `scripts/check-commit-standards.sh` 와 동일합니다. **에이전트용 트레일러**(`project:` / `agent:` / `role:` / `artifacts:`)를 쓰거나, **일반 OSS 스타일** 제목(예: `fix: …`, `Release v2.0.0`, `Fix typo in README`)이면 CI를 통과합니다. 부트스트랩 예외는 스크립트를 참고하세요.

## CI

푸시·PR 시 커밋 메시지 검사: [`.github/workflows/commit-standards.yml`](.github/workflows/commit-standards.yml)

## Sparkle 릴리즈(태그 `v*`)

### 가장 쉬운 해결 (EdDSA 오류가 날 때)

한 줄 요약: **앱 안의 “공개 키”**와 **GitHub에 넣는 “비밀 키”**는 **같은 번에 `generate_keys`로 나온 짝**이어야 하고, **릴리즈는 GitHub Actions가 DMG에 서명해서 `appcast.xml`까지 올리게** 하면 됩니다. 수동으로 DMG만 올리면 같은 오류가 납니다.

**지금 비밀 키 파일(`private.txt`)이 없거나, 헷갈리면 → 처음부터 이 순서만 따르세요.**

1. **Sparkle 도구 받기**  
   [Sparkle 릴리즈](https://github.com/sparkle-project/Sparkle/releases)에서 `Sparkle-2.x.x.tar.xz` 받아서 풉니다.

2. **터미널에서 키 만들기** (압축 푼 폴더에서 `bin`이 보이게 이동한 뒤)  
   ```bash
   ./bin/generate_keys
   ```  
   터미널에 **공개 키** 한 줄이 나오고, 같은 폴더에 **`private.txt`** 가 생깁니다.

3. **공개 키를 프로젝트에 넣기**  
   [`KillEverybodyApp.xcodeproj/project.pbxproj`](KillEverybodyApp/KillEverybodyApp.xcodeproj/project.pbxproj)를 열어 `INFOPLIST_KEY_SUPublicEDKey`가 있는 줄 **두 군데**(Debug/Release)를 모두, 방금 터미널에 나온 **공개 키 문자열**로 바꿉니다.

4. **비밀 키를 GitHub에만 넣기** (절대 커밋하지 않기)  
   같은 터미널에서:
   ```bash
   ./bin/generate_keys -x private.txt
   ```  
   출력되는 **한 줄 전체**를 복사합니다.  
   GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**  
   - Name: `SPARKLE_PRIVATE_KEY`  
   - Secret: 방금 복사한 **한 줄** 붙여넣기 → Save  

5. **변경 커밋 후 새 태그로 릴리즈**  
   `project.pbxproj` 수정분을 `main`에 푸시합니다.  
   그다음 **새 버전 태그**를 밉니다 (예: `v2.0.1`). 이미 있는 태그를 지우고 다시 쓰는 것보다 **버전 하나 올리는 편이 안전**합니다.  
   ```bash
   git tag v2.0.1
   git push origin v2.0.1
   ```  
   (버전 번호는 `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`과 맞추는 게 좋습니다.)

6. **기다렸다가 확인**  
   GitHub **Actions**에서 **Release DMG** 워크플로가 **초록색**으로 끝나면 됩니다. 실패하면 그 job 로그를 열어 빨간 스텝을 봅니다.

7. **사용자(본인) 쪽**  
   **새로 빌드된 앱(.app / DMG)** 을 설치해야 합니다. 예전 앱에는 예전 공개 키가 박혀 있어서, 키를 갈았다면 **옛 앱으로는 업데이트 확인이 계속 실패**할 수 있습니다.

---

**예전 `private.txt`가 있고, 그때 만든 공개 키가 지금 pbxproj에 그대로 있다면** 더 짧게: 4번만 하면 됩니다 — `generate_keys -x private.txt` 한 줄을 `SPARKLE_PRIVATE_KEY`에 넣고, Actions에서 **Release DMG**를 다시 돌려(또는 새 태그 푸시) **서명된 `appcast.xml`이 붙은 릴리즈**를 만듭니다.

---

아래는 같은 내용을 조금 더 기술적으로 풀어 쓴 설명입니다.

DMG와 함께 `appcast.xml`을 올리려면 저장소 **Actions secrets**에 `SPARKLE_PRIVATE_KEY`가 있어야 합니다. 값은 Sparkle `bin/generate_keys`로 만든 뒤 `bin/generate_keys -x private.txt`로 보낸 **한 줄짜리 base64 비밀 시드**(파일 내용을 그대로 붙여 넣습니다)입니다.

- 앱에 박힌 **공개 키**는 [`KillEverybodyApp.xcodeproj/project.pbxproj`](KillEverybodyApp/KillEverybodyApp.xcodeproj/project.pbxproj)의 `INFOPLIST_KEY_SUPublicEDKey`와 **반드시 짝**이 맞아야 합니다. 키를 바꾸면 공개 키를 pbxproj에 반영하고, 새 비밀 시드를 `SPARKLE_PRIVATE_KEY`에 다시 넣으세요.
- 비밀 키는 **저장소에 커밋하지 마세요.**
- 로컬에서 Sparkle 바이너리는 [Sparkle 릴리즈](https://github.com/sparkle-project/Sparkle/releases)의 `Sparkle-x.y.z.tar.xz` 안 `bin/`을 쓰면 됩니다.

### 「Fatal updater error (1): … signed with an EdDSA key」

Sparkle 2는 피드의 각 업데이트(`<enclosure>`)에 **`sparkle:edSignature`**(및 바이트 `length`)가 있어야 하고, 그 서명은 앱 Info.plist의 **`SUPublicEDKey`**(빌드 시 `INFOPLIST_KEY_SUPublicEDKey`)와 **한 쌍인 비밀 키**로 만든 것이어야 합니다.

**자주 나는 원인**

1. **`SPARKLE_PRIVATE_KEY`가 GitHub secret에 없거나**, 릴리즈 워크플로가 실패해 **수동으로 올린 `appcast.xml`에 `edSignature`가 없음**.
2. **키 불일치:** 예전 공개 키가 pbxproj에 남아 있는데 secret만 바꿈(또는 그 반대). `generate_keys`로 새로 뽑았다면 **공개 키 문자열을 pbxproj에 반영한 뒤 앱을 다시 빌드·배포**해야 합니다.
3. **DMG를 바꿨는데 appcast는 옛 서명:** 같은 태그로 DMG만 다시 올리면 서명이 깨집니다. **DMG를 바꿀 때마다** `sign_update`로 다시 서명하고 `appcast.xml`을 다시 만들어 릴리즈에 올려야 합니다.

**해결 절차(정상 페어로 맞추기)**

1. [Sparkle 릴리즈](https://github.com/sparkle-project/Sparkle/releases)의 `bin/generate_keys`로 키 생성(또는 기존 `private.txt` 유지).
2. 출력된 **공개 키**를 `project.pbxproj`의 `INFOPLIST_KEY_SUPublicEDKey`에 넣고 **앱을 새로 빌드**해 사용자에게 배포합니다.
3. `generate_keys -x private.txt`로 나온 **한 줄짜리 비밀 시드**를 저장소 **Actions → Secrets → `SPARKLE_PRIVATE_KEY`**에 넣습니다.
4. **`v*` 태그**를 푸시해 [Release DMG 워크플로](.github/workflows/release-dmg.yml)가 DMG에 `sign_update`를 적용한 뒤 **`appcast.xml`을 첨부**하도록 합니다.
5. 브라우저로 `https://github.com/<owner>/<repo>/releases/latest/download/appcast.xml`을 열어 `<enclosure … sparkle:edSignature="…" length="…"/>`가 있는지 확인합니다.
6. (선택) 저장소 루트에서 `./scripts/verify-sparkle-appcast.sh`를 실행해 같은 URL에 `edSignature`·`length`가 있는지 빠르게 확인할 수 있습니다.

공식 설명: [Sparkle 문서 — EdDSA (서명)](https://sparkle-project.org/documentation/eddsa-migration/).

### 「Unable to Check For Updates」/ updater failed to start

1. **번들 구조:** 빌드·설치한 `killeverybody.app`에서 아래가 있는지 확인합니다.
   - `Contents/Frameworks/Sparkle.framework`
   - `Sparkle.framework/Versions/Current/Resources/Autoupdate.app` (및 `Updater.app` 등 Sparkle가 동봉하는 헬퍼)
2. **서명·Hardened Runtime:** GitHub Actions·로컬 **서명 없음(ad-hoc)** 빌드에서는 Hardened Runtime이 Sparkle 내부 바이너리 실행을 막아 같은 메시지가 날 수 있습니다. 대응은 (가) 앱·`Sparkle.framework`·내부 앱을 **같은 개발자 ID로 서명**하거나, (나) **개발·비배포용으로만** `KillEverybodyApp.entitlements`에 `com.apple.security.cs.disable-library-validation` 추가를 검토합니다(보안이 약해지므로 배포 정책과 별도 판단).
3. **로그:** 앱은 `SPUUpdaterDelegate`로 Sparkle 오류를 **OSLog**(`subsystem` = 앱 번들 ID, `category` = `Sparkle`)에 남깁니다. 터미널에서 재현하면서 보려면 예시는 다음과 같습니다.

```bash
log stream --predicate 'subsystem == "com.github.LPFchan.KillEverybody" AND category == "Sparkle"' --level debug
```

(번들 ID를 바꿨다면 `subsystem`을 해당 값으로 바꿉니다.)

## 스모크

[`docs/smoke-test.md`](docs/smoke-test.md) 체크리스트를 참고하세요.

## 라이선스

기여는 [LICENSE](LICENSE)(MIT)에 따릅니다. 큰 동작·정책 변경은 `SPEC.md` / `PLANS.md`와 맞는지 확인해 주세요.
