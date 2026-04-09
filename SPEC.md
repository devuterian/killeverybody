# KillEverybody Spec

## Project

- **Project:** KillEverybody
- **Canonical repo:** [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- **Project id:** `killeverybody`
- **Primary surface:** macOS SwiftUI 앱 — [`KillEverybodyApp/`](KillEverybodyApp/)
- **Last updated:** 2026-04-09 (정책 JSON·메뉴바 프리셋·MIT 반영)

## Project thesis

로그인 세션에서 **메뉴바·에이전트로 간주되는 앱(LSUIElement 등)과 시스템 필수 프로세스는 제외**하고, 사용자가 선택한 범위 안에서 나머지를 **미리보기 후 `SIGKILL`로 강제 종료**할 수 있게 한다. 아이디어·실행 기록·결정은 repo-template 관례(`REPO.md`, `records/` 등)에 둔다.

## Core capabilities

- 범위 선택: **GUI 앱만**, **현재 사용자 UID 프로세스 전체**, **관리자 권한(실험적, 동일 대상 + osascript)**.
- 보호: 고정 **denylist**, 번들 **LSUIElement**, 사용자 **예외 번들 ID**, 사용자 **메뉴 막대 취급 번들**, 코드에 넣은 **메뉴 막대 도구 번들 프리셋**, **자기 PID** 제외.
- 설정 **정책 JSON** 보내기/가져오기로 예외·메뉴바 번들 목록을 옮길 수 있다.
- 앱 메뉴에서 **Releases** 페이지를 연다(자동 업데이트 Sparkle은 미도입).
- 흐름: 범위 선택 → **대상 수집** → 테이블 미리보기 → 확인 후 종료.

## Invariants

- 시스템 핵심 프로세스(`launchd`, `WindowServer`, `kernel_task` 등)는 denylist로 **코드에 고정**해 후보에서 제외한다.
- 종료 실행 전에 **항상** 미리보기와 확인 단계가 있어야 한다(무분별한 원클릭 전체 kill 금지).
- 메뉴바 판별은 **공개 API 휴리스틱**(LSUIElement + 사용자 예외·메뉴바 취급 + 프리셋)이며 완벽하지 않다는 점을 사용자 문서에 명시한다.

## Non-goals

- App Store 샌드박스 제품으로의 제출(프로세스 kill에 적합하지 않음).
- 메뉴바 앱의 100% 정확한 자동 분류(비공개 API·프라이빗 상태 의존 회피).
- 데이터 손실·시스템 불안정에 대한 보증(도구는 고위험 실험용).

## Success criteria

- Xcode에서 빌드·실행 가능하고, README(한국어)만으로 빌드 절차를 따라갈 수 있다.
- 세 가지 범위와 예외 번들 설정이 UI에서 동작한다.

## Related decisions

- (초기) repo 베이스: [LPFchan/repo-template](https://github.com/LPFchan/repo-template) scaffold 채택, `upstream-intake` 미포함.
