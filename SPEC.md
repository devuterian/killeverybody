# KillEverybody Spec

## Project

- **Project:** KillEverybody
- **Canonical repo:** [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- **Project id:** `killeverybody`
- **Primary surface:** macOS SwiftUI 앱 — [`KillEverybodyApp/`](KillEverybodyApp/)
- **Last updated:** 2026-04-09 (v2.0.0·영감 출처 README 반영)

## Project thesis

로그인 세션에서 사용자가 **명시적으로 확인**한 뒤, 선택한 모드에 따라 **현재 사용자 UID 프로세스**를 `SIGKILL`로 강제 종료할 수 있게 한다. **적당히 죽이기** 모드에서는 메뉴바·에이전트로 간주되는 앱(LSUIElement 등)과 시스템 필수 프로세스·사용자 예외를 제외한다. **다죽이기** 모드는 denylist만 제외하고 메뉴바·LSUIElement·예외 번들 보호를 적용하지 않는다. 아이디어·실행 기록·결정은 repo-template 관례(`REPO.md`, `records/` 등)에 둔다.

## Core capabilities

- 메인 창: 중앙 질문 **「다 죽일까요?」**와 버튼 **다죽이기**(destructive) / **적당히 죽이기**(노란 강조) / **종료**. 실행 전 **확인 알림**(종료 개수·저장 경고).
- **다죽이기:** 현재 사용자 UID 프로세스 중 **denylist만** 제외(예외 번들·메뉴바 프리셋·LSUIElement 스킵 없음).
- **적당히 죽이기:** denylist + 사용자 **예외 번들 ID** + **메뉴 막대 취급 번들** + 프리셋 + **LSUIElement** 스킵(기존 `collectUserProcesses` 보호와 동일).
- 설정(예외·정책 JSON·프리셋): **앱 메뉴 → 설정…**(⌘,) 시트로만 연다.
- 앱 메뉴에서 **Releases** 페이지를 열고, **Sparkle**로 주기적 업데이트 확인·DMG 기반 설치를 제공한다(피드: `releases/latest/download/appcast.xml`). `Sparkle.framework`는 앱 번들 `Contents/Frameworks`에 임베드한다.
- 문서: 루트 [`README.md`](README.md)(한국어), [`README.en.md`](README.en.md), [`README.ja.md`](README.ja.md) 상호 링크.

## Invariants

- 시스템 핵심 프로세스(`launchd`, `WindowServer`, `kernel_task` 등)는 denylist로 **코드에 고정**해 후보에서 제외한다.
- 종료 실행 전에 **확인 단계**(알림)가 있어야 한다. 테이블 미리보기는 사용하지 않는다.
- **적당히 죽이기**에서 메뉴바 판별은 **공개 API 휴리스틱**(LSUIElement + 사용자 예외·메뉴바 취급 + 프리셋)이며 완벽하지 않다는 점을 사용자 문서에 명시한다.

## Non-goals

- App Store 샌드박스 제품으로의 제출(프로세스 kill에 적합하지 않음).
- 메뉴바 앱의 100% 정확한 자동 분류(비공개 API·프라이빗 상태 의존 회피).
- 데이터 손실·시스템 불안정에 대한 보증(도구는 고위험 실험용).

## Success criteria

- Xcode에서 빌드·실행 가능하고, README(한국어)만으로 빌드 절차를 따라갈 수 있다.
- 두 가지 킬 모드와 예외 번들 설정이 UI·메뉴에서 동작한다.

## Related decisions

- (초기) repo 베이스: [LPFchan/repo-template](https://github.com/LPFchan/repo-template) scaffold 채택, `upstream-intake` 미포함.
- 제품 컨셉의 영감: 키플러(kippler)의 Windows용 **다죽여**(AllKill) — [http://kippler.com/allkill/](http://kippler.com/allkill/) (별도 제품·라이선스; 본 macOS 앱은 독립 구현).
