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

규칙은 `scripts/check-commit-standards.sh` 와 동일합니다. 부트스트랩 예외는 스크립트 주석을 참고하세요.

## CI

푸시·PR 시 커밋 트레일러 검사: [`.github/workflows/commit-standards.yml`](.github/workflows/commit-standards.yml)

## 스모크

[`docs/smoke-test.md`](docs/smoke-test.md) 체크리스트를 참고하세요.

## 라이선스

기여는 [LICENSE](LICENSE)(MIT)에 따릅니다. 큰 동작·정책 변경은 `SPEC.md` / `PLANS.md`와 맞는지 확인해 주세요.
