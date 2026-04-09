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

DMG와 함께 `appcast.xml`을 올리려면 저장소 **Actions secrets**에 `SPARKLE_PRIVATE_KEY`를 넣어야 합니다. 값은 Sparkle `bin/generate_keys`로 만든 뒤 `bin/generate_keys -x private.txt`로 보낸 **한 줄짜리 base64 비밀 시드**(파일 내용을 그대로 붙여 넣습니다)입니다.

- 앱에 박힌 **공개 키**는 [`KillEverybodyApp.xcodeproj/project.pbxproj`](KillEverybodyApp/KillEverybodyApp.xcodeproj/project.pbxproj)의 `INFOPLIST_KEY_SUPublicEDKey`와 **반드시 짝**이 맞아야 합니다. 키를 바꾸면 공개 키를 pbxproj에 반영하고, 새 비밀 시드를 `SPARKLE_PRIVATE_KEY`에 다시 넣으세요.
- 비밀 키는 **저장소에 커밋하지 마세요.**
- 로컬에서 Sparkle 바이너리는 [Sparkle 릴리즈](https://github.com/sparkle-project/Sparkle/releases)의 `Sparkle-x.y.z.tar.xz` 안 `bin/`을 쓰면 됩니다.

## 스모크

[`docs/smoke-test.md`](docs/smoke-test.md) 체크리스트를 참고하세요.

## 라이선스

기여는 [LICENSE](LICENSE)(MIT)에 따릅니다. 큰 동작·정책 변경은 `SPEC.md` / `PLANS.md`와 맞는지 확인해 주세요.
