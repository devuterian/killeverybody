# 수동 스모크 테스트 (실제 Mac)

CI는 GUI 앱을 대신 눌러 주지 않으니, **릴리즈 전·큰 변경 후** 아래를 맥에서 한 번씩 확인합니다.

## 준비

- [ ] 테스트용으로만 써도 되는 사용자 계정이 있으면 더 안전합니다.
- [ ] 중요한 문서는 저장해 둡니다.

## 메인 다이얼로그

- [ ] killeverybody 실행 → 중앙에 **「다 죽일까요?」**와 세 버튼이 보입니다.
- [ ] **적당히 죽이기** → 확인 알림에서 개수를 본 뒤 취소할 수 있습니다.
- [ ] 메모·미리보기 등 닥 앱을 켠 상태에서 **적당히 죽이기** 후보가 기대와 맞는지(메뉴바·LSUIElement 등은 스킵되는지) 봅니다.
- [ ] **다죽이기**는 denylist 외 보호가 덜하므로, 테스트 계정에서만 동작을 확인합니다.
- [ ] `launchd`, `WindowServer` 같은 이름은 후보에 **없어야** 합니다 (denylist).

## 설정 (⌘,)

- [ ] **설정…**에서 예외 번들·메뉴바 번들·정책 JSON보내기/가져오기가 동작합니다.

## Sparkle

- [ ] **업데이트 확인…**이 오류 없이 열리고, 빌드 산출물에 `killeverybody.app/Contents/Frameworks/Sparkle.framework`가 있습니다.
- [ ] 같은 프레임워크 안에 `Autoupdate.app`(등 헬퍼)이 들어 있는지 확인합니다.
- [ ] 「The updater failed to start」가 나오면 [CONTRIBUTING.md](../CONTRIBUTING.md)(Sparkle 절)의 번들·서명·로그 절차를 따릅니다. 앱은 Console에서 `subsystem` = 번들 ID, `category` = `Sparkle` 로그를 남깁니다.
- [ ] 「Fatal updater error … EdDSA」는 피드 서명·`SUPublicEDKey`·`SPARKLE_PRIVATE_KEY` 짝이 안 맞을 때입니다. [CONTRIBUTING.md](../CONTRIBUTING.md)의 해당 소절을 따릅니다.

실패한 항목은 [Issues](https://github.com/devuterian/killeverybody/issues)에 OS 버전·앱 버전과 함께 적어 주세요.
