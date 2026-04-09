# KillEverybody Status

## Snapshot

- **Last updated:** 2026-04-09
- **Overall posture:** `active`
- **Current focus:** README(사용자 톤)·`PLANS.md` 로드맵과 README 정합
- **Highest-priority blocker:** 없음(로컬에서 Xcode 전체 설치·서명은 운영자 환경에 따름)
- **Next operator decision needed:** `LICENSE` 채택 여부·(선택) Sparkle·서명 재개 시점
- **Related decisions:** (아직 `DEC-*` 없음)

## Current State Summary

`KillEverybodyApp/`에 SwiftUI macOS 앱이 있다. `NSWorkspace`·`/bin/ps`·`proc_pidpath`로 후보를 모으고, denylist·LSUIElement·예외 번들로 필터한 뒤 테이블에 표시한다. 관리자 모드는 `NSAppleScript`로 `kill -9`를 실행한다. repo-template 산출물(`REPO.md`, `skills/`, 커밋 검사 스크립트 등)이 루트에 있다.

## Active Phases Or Tracks

### App MVP

- **Goal:** 계획된 3단 범위·미리보기·kill·예외 번들 설정 구현
- **Status:** `done`
- **Why this matters now:** 저장소 공개 전 최소 사용 가능 제품
- **Current work:** 구현 완료, 실제 기기에서 Xcode 빌드 검증은 운영자가 수행
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

- **2026-04-09**
  - **Change:** repo-template scaffold + KillEverybody macOS 앱 추가; 이후 README(토스 톤)·DMG/보안 안내 정리 및 `PLANS.md`에 서명 보류·Sparkle·LICENSE 방향 명시
  - **Why it matters:** 단일 저장소에서 제품·규율·사용자 문서 전제를 맞춤
  - **Related ids:** `LOG-20260409-001`

## Active Blockers And Risks

- **Risk:** 메뉴바 판별 한계로 의도치 않은 앱이 종료되거나 남을 수 있음
  - **Effect:** 데이터 손실·워크플로 중단
  - **Owner:** 운영자
  - **Mitigation:** 예외 번들 목록·GUI-only 모드 우선 사용
  - **Related ids:** —

## Immediate Next Steps

- **Next:** (선택) `LICENSE` 결정·추가
  - **Owner:** 운영자
  - **Trigger:** 공개·재배포 의도 확정
  - **Related ids:** —
