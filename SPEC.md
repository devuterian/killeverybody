# KillEverybody Spec

## Project

- **Project:** KillEverybody
- **Canonical repo:** [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- **Project id:** `killeverybody`
- **Primary surface:** macOS SwiftUI 앱 — [`KillEverybodyApp/`](KillEverybodyApp/)
- **Last updated:** 2026-08-15 (권한 없는 로그인 앱 조회·Sparkle 자동 업데이트)

## Project thesis

로그인 세션에서 실행 중인 **앱과 그 자식 프로세스**를 `SIGKILL`로 강제 종료한다. **적당히 죽이기**는 메뉴바·에이전트로 간주되는 앱(LSUIElement 등)과 사용자 예외를 제외하고, **다죽이기**는 사용자 예외를 적용하지 않는다. 자동 재실행되는 서드파티 앱은 일치하는 LaunchAgent를 현재 GUI 세션에서만 내린다. 아이디어·실행 기록·결정은 repo-template 관례(`REPO.md`, `records/` 등)에 둔다.

## Core capabilities

- 메인 창: 시스템 `NSAlert`에 앱 아이콘·질문 **「다 죽일까요?」**와 **다죽이기 / 적당히 죽이기 / 예외 앱… / 종료** 버튼을 둔다. 종료 버튼은 추가 확인 없이 바로 실행한다.
- **다죽이기:** 실행 중인 앱과 자식 프로세스 중 고정 denylist와 killeverybody 자신만 제외한다. 사용자 예외·메뉴바 프리셋·LSUIElement 보호는 적용하지 않는다.
- **적당히 죽이기:** 같은 앱 중심 범위에서 사용자 예외 번들 ID + 메뉴 막대 취급 번들 + 프리셋 + LSUIElement를 제외한다.
- **예외 앱:** 설치 앱을 아이콘·이름·번들 ID로 보여 주고 전체 앱·실행 중·로그인 시 실행 필터와 검색을 제공한다. 체크는 즉시 저장하며, 첫 실행 때 읽기 전용 SharedFileList에서 찾은 로그인 앱을 기본 예외로 한 번만 넣는다. 로그인 앱 조회는 관리자 암호를 요구하지 않는다.
- 앱 헬퍼는 가장 바깥쪽 앱 번들로 묶는다. 일치하는 서드파티 LaunchAgent는 현재 GUI 세션에서만 `bootout`하며 plist는 수정하지 않는다.
- 종료가 모두 성공하면 결과 창 없이 killeverybody도 정상 종료한다. 일부 실패 때만 결과와 관리자 재시도를 보여 준 뒤 종료한다.
- 앱 메뉴에서 **Releases** 페이지를 열고, **Sparkle**로 실행 직후와 예약 시점에 업데이트를 확인하며 가능한 업데이트는 자동으로 내려받아 설치한다(피드: `releases/latest/download/appcast.xml`). 릴리스 CI는 프로젝트가 쓰는 Sparkle 버전의 공식 `generate_appcast`로 EdDSA 서명 피드를 만든다. `Sparkle.framework`는 앱 번들 `Contents/Frameworks`에 임베드하고, 오류는 OSLog(`category: Sparkle`)에 남긴다.
- 문서: 루트 [`README.md`](README.md)(한국어), [`README.en.md`](README.en.md), [`README.ja.md`](README.ja.md) 상호 링크.

## Invariants

- 시스템 핵심 프로세스(`launchd`, `WindowServer`, `kernel_task` 등)는 denylist로 **코드에 고정**해 후보에서 제외한다.
- 종료 버튼 뒤에 추가 확인 단계나 테이블 미리보기를 넣지 않는다.
- **적당히 죽이기**에서 메뉴바 판별은 **공개 API 휴리스틱**(LSUIElement + 사용자 예외·메뉴바 취급 + 프리셋)이며 완벽하지 않다는 점을 사용자 문서에 명시한다.

## Non-goals

- App Store 샌드박스 제품으로의 제출(프로세스 kill에 적합하지 않음).
- 메뉴바 앱의 100% 정확한 자동 분류(비공개 API·프라이빗 상태 의존 회피).
- 데이터 손실·시스템 불안정에 대한 보증(도구는 고위험 실험용).

## Success criteria

- Xcode에서 빌드·실행 가능하고, README(한국어)만으로 빌드 절차를 따라갈 수 있다.
- 두 가지 킬 모드, 검색 가능한 예외 앱 설정, 첫 실행 로그인 앱 기본값, 세션 LaunchAgent 억제가 동작한다.

## Related decisions

- (초기) repo 베이스: [LPFchan/repo-template](https://github.com/LPFchan/repo-template) scaffold 채택, `upstream-intake` 미포함.
- 제품 컨셉의 영감: 키플러(kippler)의 Windows용 **다죽여**(AllKill) — [http://kippler.com/allkill/](http://kippler.com/allkill/) (별도 제품·라이선스; 본 macOS 앱은 독립 구현).
