# 수동 스모크 테스트 (실제 Mac)

CI는 GUI 앱을 대신 눌러 주지 않으니, **릴리즈 전·큰 변경 후** 아래를 맥에서 한 번씩 확인합니다.

## CLI로 후보 목록만 (GUI 없이)

앱과 동일한 앱·자식 프로세스 종료 후보를 **터미널에서** 확인하려면 `killeverybody-cli`를 빌드한 뒤 [`docs/build.md`](build.md)의 CLI 절을 따르세요.

- [ ] `killeverybody-cli --dry-run` 또는 `--dry-run --json`으로 개수·PID가 기대와 맞는지 봅니다.
- [ ] 실행 중인 앱과 그 자식 프로세스만 후보에 있고, 같은 UID라는 이유만으로 셸·시스템 에이전트가 섞이지 않는지 봅니다.
- [ ] 정책 JSON에 넣은 앱은 `--moderate`에서 앱 헬퍼까지 빠지고, `--aggressive`에서는 다시 포함되는지 봅니다.
- [ ] `--execute`는 데이터 손실이므로 **테스트 전용 계정**에서만 사용합니다.

## 준비

- [ ] 테스트용으로만 써도 되는 사용자 계정이 있으면 더 안전합니다.
- [ ] 중요한 문서는 저장해 둡니다.

## 메인 다이얼로그

- [ ] killeverybody 실행 → 중앙에 **「다 죽일까요?」**와 다죽이기·적당히 죽이기·예외 앱…·종료 버튼이 보입니다.
- [ ] 메모·미리보기 등 Dock 앱을 켠 상태에서 `--dry-run` 후보가 기대와 맞는지 봅니다.
- [ ] **다죽이기**는 denylist 외 보호가 덜하므로, 테스트 계정에서만 동작을 확인합니다.
- [ ] 성공 시 별도 결과 창 없이 killeverybody도 종료되고, 실패 시에만 결과 창이 뜹니다.

## 예외 앱

- [ ] 메인 알림의 **예외 앱…**에서 아이콘·앱 이름·번들 ID가 보입니다.
- [ ] 전체 앱·실행 중·로그인 시 실행 필터와 이름·번들 ID·경로 검색이 동작합니다.
- [ ] 첫 실행 때 로그인 앱이 기본 체크되고, 체크 변경이 재실행 뒤에도 유지됩니다.
- [ ] 앱 실행과 로그인 필터 조회 때 `sfltool` 관리자 암호 창이 뜨지 않습니다.
- [ ] 앱 하나를 예외로 두면 그 앱의 헬퍼도 `--moderate` 후보에서 빠집니다.
- [ ] 고급 탭에서 번들 ID 직접 추가·메뉴바 번들·정책 JSON 보내기/가져오기가 동작합니다.

## Sparkle

- [ ] **업데이트 확인…**이 오류 없이 열리고, 빌드 산출물에 `killeverybody.app/Contents/Frameworks/Sparkle.framework`가 있습니다.
- [ ] 앱 실행 직후 백그라운드 확인이 시작되고, 빌드 Info.plist의 `SUEnableAutomaticChecks`·`SUAutomaticallyUpdate`가 모두 `true`입니다.
- [ ] 같은 프레임워크 안에 `Autoupdate.app`(등 헬퍼)이 들어 있는지 확인합니다.
- [ ] 「The updater failed to start」가 나오면 [CONTRIBUTING.md](../CONTRIBUTING.md)(Sparkle 절)의 번들·서명·로그 절차를 따릅니다. 앱은 Console에서 `subsystem` = 번들 ID, `category` = `Sparkle` 로그를 남깁니다.
- [ ] 「Fatal updater error … EdDSA」는 피드 서명·`SUPublicEDKey`·`SPARKLE_PRIVATE_KEY` 짝이 안 맞을 때입니다. [CONTRIBUTING.md](../CONTRIBUTING.md)의 해당 소절을 따릅니다.

실패한 항목은 [Issues](https://github.com/devuterian/killeverybody/issues)에 OS 버전·앱 버전과 함께 적어 주세요.
