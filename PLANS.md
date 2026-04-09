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
- **진행:** 내장 **프리셋 번들** + 설정의 **메뉴 막대로 취급할 번들**이 반영됨. 머신러닝·자동 학습은 미구현.
- **Related ids:** —

### Signed release / notarization

- **Outcome:** 아카이브·노타라이즈된 `.app` 또는 `.dmg`를 Release에 올린다.
- **Why this is accepted:** Gatekeeper 환경에서 설치 마찰을 줄이기 위해.
- **Expected value:** 다운로드 즉시 실행 가능성 향상.
- **Preconditions:** Apple Developer ID, CI 또는 로컬 릴리스 절차.
- **Earliest likely start:** 운영자 여건이 갖춰진 뒤(현재 **보류**).
- **현재 상태:** README·릴리즈는 **서명 없는 CI DMG** 전제로 안내한다(우클릭 열기·시스템 설정 허용).
- **Related ids:** —

### 릴리즈에서 최신 DMG 찾기(Sparkle 등)

- **Outcome:** DMG 사용자가 **항상 같은 곳**(README의 [Releases](https://github.com/devuterian/killeverybody/releases) 링크, 또는 Sparkle 자동 업데이트)으로 최신 빌드를 찾게 한다.
- **Why this is accepted:** 태그마다 URL이 바뀌지 않게 하고, 업데이트 마찰을 줄이기 위해.
- **Expected value:** 재방문·재설치가 단순해짐.
- **Preconditions:** 배포 채널 결정(Sparkle이면 키·호스트 정책).
- **Earliest likely start:** 사용자 피드백 후.
- **진행:** README 링크 + 앱 메뉴 **「최신 릴리즈 열기…」** 반영. **Sparkle 자동 업데이트**는 미도입(서명 보류와 맞물림).
- **Related ids:** —

### LICENSE 파일 명시

- **Outcome:** 저장소 루트에 `LICENSE`를 두고 README의 라이선스 문단과 맞춘다.
- **Why this is accepted:** README에 “파일 없으면 권리는 작성자” 안내가 이미 있음; 의도(오픈 소스 여부)를 명확히 하기 위해.
- **Expected value:** 포크·재배포 기대치가 분명해짐.
- **Preconditions:** 운영자의 라이선스 선택.
- **Earliest likely start:** 공개 범위를 정할 때.
- **진행:** 루트 [LICENSE](LICENSE)(MIT) 추가·README 반영 완료.
- **Related ids:** —

## Sequencing

### Near Term

- **Initiative:** 실제 Mac에서 GUI-only / 사용자 전체 모드 스모크 테스트
  - **Why now:** CI에서 macOS GUI 앱을 돌리기 어렵다.
  - **Dependencies:** Xcode 설치된 기기.
  - **Related ids:** `LOG-20260409-001`

- **Initiative:** `LICENSE` 추가 여부 결정 및 README 라이선스 문단과 정합
  - **Status:** 완료(MIT).
  - **Related ids:** —

- **Initiative:** `scripts/smoke-check.sh` + [`docs/smoke-test.md`](docs/smoke-test.md)로 타입검사·수동 체크 경로 제공
  - **Status:** 반영됨.
  - **Related ids:** —

### Mid Term

- **Initiative:** denylist·예외 목록을 파일 또는 설정 UI로보내기/가져오기
  - **Status:** 예외·메뉴바 번들은 **정책 JSON**으로 보내기/가져오기 구현. **denylist 자체** 편집·가져오기는 미구현.
  - **Related ids:** —

- **Initiative:** Sparkle 등 자동 업데이트 또는 릴리즈 안내 고정화(위 Approved Directions 참고)
  - **Why later:** DMG 수동 재다운로드 부담이 쌓일 때.
  - **Dependencies:** 서명·업데이트 채널 정책.
  - **Related ids:** —

### Deferred But Accepted

- **Initiative:** `upstream-intake` 모듈 도입(상위 템플릿 추적 시)
  - **Why deferred:** 현재 단일 제품 포크로 upstream 추적 불필요.
  - **Revisit trigger:** repo-template 대량 머지 필요 시.
  - **Related ids:** —
