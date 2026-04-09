Opened            2026-04-09 22-30-00 KST
Recorded by agent | cursor

# LOG-20260409-001 — KillEverybody 초기 구현

## Summary

- [LPFchan/repo-template](https://github.com/LPFchan/repo-template) scaffold를 루트에 반영(`upstream-intake` 제외).
- `KillEverybodyApp/` SwiftUI macOS 앱: 범위 3종, denylist·LSUIElement·예외 번들, 미리보기 후 kill·관리자 모드(osascript).
- `SPEC.md` / `STATUS.md` / `PLANS.md`를 제품에 맞게 갱신.

## Notes

- 빌드 검증: 환경에 Xcode 앱이 없으면 `xcodebuild`는 실패할 수 있음. `swiftc -typecheck`로 소스 타입 검사 완료.

## Related

- `SPEC.md`, `STATUS.md`, `README.md`
