# KillEverybody Status

## Snapshot

- **Last updated:** 2026-08-15
- **Overall posture:** `active`
- **Current focus:** 3.0.0 이후 예외 목록 UX·앱 현지화
- **Highest-priority blocker:** 없음(로컬에서 Xcode 전체 설치·서명은 운영자 환경에 따름)
- **Next operator decision needed:** (선택) 서명·노타라이즈 재개 시점·denylist 가져오기 필요 여부. Sparkle EdDSA secret은 GitHub에 설정돼 있다.
- **Related decisions:** `DEC-20260815-001`

## Current State Summary

`KillEverybodyApp/`의 현재 제품 버전은 **3.0.0(빌드 18)**이다. 종료 후보는 실행 중인 앱과 자식 프로세스로 제한하며, 앱 단위 예외·LSUIElement·메뉴바 프리셋·세션 LaunchAgent 억제를 제공한다. 예외 앱 화면은 설치 앱 아이콘·검색·필터·자동 저장·3가지 정렬·단일 앱 우클릭 강제 종료를 지원한다. 한국어·English·日本語를 앱 안에서 직접 고를 수 있고, 권한 창 없는 읽기 전용 API로 로그인 앱을 찾아 첫 실행 기본값으로 쓴다. 정책 JSON, CLI dry-run, Releases 링크와 Sparkle 자동 확인·설치도 유지한다.

## Active Phases Or Tracks

### App MVP

- **Goal:** 앱 중심 두 종료 모드·예외 앱 목록·재실행 억제 구현
- **Status:** `done`
- **Why this matters now:** 저장소 공개 전 최소 사용 가능 제품
- **Current work:** 3.0.0 앱·CLI Release 클린 빌드, 정책 dry-run, 격리 LaunchAgent, 권한 없는 실행, Sparkle appcast 생성 검증 완료
- **Exit criteria:** 소스·프로젝트·한국어 README 존재
- **Dependencies:** macOS 13+, Xcode(권장)
- **Risks:** 잘못된 범위 선택 시 데이터 손실
- **Related ids:** `LOG-20260409-001`

### GitHub publication

- **Goal:** 원격 저장소에 푸시·README·릴리즈(DMG)
- **Status:** `done`
- **Why this matters now:** 배포 요청
- **Current work:** 공개 저장소·태그 릴리즈·CI DMG 업로드 완료([README.md](README.md), [Releases](https://github.com/devuterian/killeverybody/releases))
- **Exit criteria:** 원격 `main`에 푸시
- **Dependencies:** —
- **Risks:** 없음
- **Related ids:** —

## Recent Changes To Project Reality

- **2026-08-15**
  - **Change:** 예외 앱 목록에 저장되는 3가지 정렬과 단일 앱 우클릭 강제 종료를 추가하고, 앱 전체 UI를 한국어·영어·일본어로 즉시 전환할 수 있게 함.
  - **Why it matters:** 보호 상태를 빠르게 훑고 특정 앱만 정리할 수 있으며, 시스템 언어와 무관하게 원하는 UI 언어를 쓸 수 있음.
  - **Related ids:** `LOG-20260815-001`

- **2026-08-15**
  - **Change:** 관리자 암호를 요구하던 `sfltool` 로그인 앱 조회를 제거하고, Sparkle 2.9.5·시작 시 백그라운드 확인·자동 설치·공식 appcast 생성으로 갱신.
  - **Why it matters:** 매 실행 권한 창을 없애고 짧게 실행되는 앱에서도 GitHub Release 업데이트를 놓치지 않게 함.
  - **Related ids:** `LOG-20260815-001`

- **2026-08-15**
  - **Change:** 같은 UID 전체 종료를 앱+자식 프로세스 중심으로 좁힘. 검색 가능한 예외 앱 화면, 최초 1회 로그인 앱 기본값, 앱 헬퍼 묶기, 서드파티 LaunchAgent 세션 bootout, 성공 후 자체 정상 종료를 구현.
  - **Why it matters:** 시스템 에이전트 오종료를 줄이고, 사용자 예외와 자동 재실행 억제를 실제 앱 단위로 맞춤.
  - **Related ids:** `DEC-20260815-001`, `LOG-20260815-001`

- **2026-04-09**
  - **Change:** repo-template scaffold + KillEverybody macOS 앱 추가; README(토스 톤)·DMG/보안·`PLANS` 정합; 로드맵(서명 제외) 구현 — denylist 보강, 메뉴바 프리셋·사용자 메뉴바 번들, 정책 JSON, Releases 메뉴, MIT·CONTRIBUTING·docs·스모크 스크립트·CI 타입체크
  - **Why it matters:** 단일 저장소에서 제품·규율·사용자 문서·배포 경로를 맞춤
  - **Related ids:** `LOG-20260409-001`

## Active Blockers And Risks

- **Risk:** 메뉴바 판별 한계로 의도치 않은 앱이 종료되거나 남을 수 있음
  - **Effect:** 데이터 손실·워크플로 중단
  - **Owner:** 운영자
  - **Mitigation:** 로그인 앱 최초 기본 예외·앱 단위 체크·CLI dry-run 사용
  - **Related ids:** —

## Immediate Next Steps

- **Next:** 실제 사용자 계정에서 전체 종료는 하지 않고 CLI dry-run과 격리 LaunchAgent 테스트를 유지한다.
  - **Owner:** 운영자
  - **Trigger:** 릴리즈 전
  - **Related ids:** `LOG-20260815-001`
