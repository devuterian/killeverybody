# KillEverybody Plans

## Planning Rules

- Only accepted future direction belongs here.
- Plans should be specific enough to guide execution later.
- Product or architecture rationale should link to `DEC-*` records when relevant.
- When a plan becomes current truth, reflect it into `SPEC.md` or `STATUS.md` and update this file.

## Approved Directions

### Stronger menu-bar and agent detection

- **Outcome:** LSUIElement 외 휴리스틱(예: 사용자 피드백 기반 학습, 알려진 번들 목록 옵션)을 **선택 적용**해 오탐·미탐을 줄인다.
- **Why this is accepted:** “메뉴바 제외” 요구와 실제 판별 오차를 줄이기 위해.
- **Expected value:** 덜 위험한 기본 경험.
- **Preconditions:** 실사용 로그·이슈 수집.
- **Earliest likely start:** MVP 공개 후.
- **Related ids:** —

### Signed release / notarization

- **Outcome:** 아카이브·노타라이즈된 `.app` 또는 `.dmg`를 Release에 올린다.
- **Why this is accepted:** Gatekeeper 환경에서 설치 마찰을 줄이기 위해.
- **Expected value:** 다운로드 즉시 실행 가능성 향상.
- **Preconditions:** Apple Developer ID, CI 또는 로컬 릴리스 절차.
- **Earliest likely start:** 필요 시.
- **Related ids:** —

## Sequencing

### Near Term

- **Initiative:** 실제 Mac에서 GUI-only / 사용자 전체 모드 스모크 테스트
  - **Why now:** CI에서 macOS GUI 앱을 돌리기 어렵다.
  - **Dependencies:** Xcode 설치된 기기.
  - **Related ids:** `LOG-20260409-001`

### Mid Term

- **Initiative:** denylist·예외 목록을 파일 또는 설정 UI로보내기/가져오기
  - **Why later:** 팀·여러 머신에서 동일 정책 재사용.
  - **Dependencies:** 제품 사용 피드백.
  - **Related ids:** —

### Deferred But Accepted

- **Initiative:** `upstream-intake` 모듈 도입(상위 템플릿 추적 시)
  - **Why deferred:** 현재 단일 제품 포크로 upstream 추적 불필요.
  - **Revisit trigger:** repo-template 대량 머지 필요 시.
  - **Related ids:** —
