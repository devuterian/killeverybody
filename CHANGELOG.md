# Changelog

앞으로 **바뀐 것만** 짧게 적습니다 (날짜 + 불릿).

## 2.0.2

- Sparkle **EdDSA 키 재발급**: `INFOPLIST_KEY_SUPublicEDKey` 갱신, GitHub Actions secret `SPARKLE_PRIVATE_KEY`를 짝 맞는 시드로 설정. 빌드 번호 12. (업데이트 확인 EdDSA 오류 해소용 릴리즈)

## 2.0.0

- 마케팅 버전 **2.0.0**.
- README·SPEC에 영감 출처 명시: 키플러(kippler)의 Windows용 **다죽여**(AllKill) — [http://kippler.com/allkill/](http://kippler.com/allkill/).
- CI/Release: SPM `Sparkle.framework` 임베드 스크립트 — `BUILD_DIR` find 보강, 앱 번들 존재 확인, 빌드 페이즈를 링크 직후(Resources 앞)로 이동. 빌드 번호 10.
- 메인 UI: 앱 아이콘·회색 카드·캡슐형 버튼만(부가 설명 제거). 종료 후 피드백은 SIGKILL 일부 실패 시에만 알림.
- Sparkle: `SPUUpdaterDelegate`로 OSLog(`category: Sparkle`) 기록; CONTRIBUTING·스모크에 업데이터 실패 점검 절차.

## 1.3.0

- README 한국어·영어·일본어 분리 및 상호 링크(`README.md`, `README.en.md`, `README.ja.md`).
- 메인 UI를 **「다 죽일까요?」** 다이얼로그로 단순화(다죽이기 / 적당히 죽이기 / 종료, 확인 알림). 설정은 메뉴 ⌘,만.
- Sparkle: `Sparkle.framework`를 앱 번들에 Embed, 업데이터 초기화 시점 정리.

## 1.2.0

- Sparkle 자동 업데이트(피드: GitHub Release `appcast.xml`, 메뉴 「업데이트 확인…」).

## 1.1.1

- 앱 표시명·제품명·`.app` 이름 `killeverybody` 통일, 아이콘·표시명 Info 키 명시.
- 정책 보내기 기본 파일명 `killeverybody-policy.json`, `CHANGELOG.md` 추가.
