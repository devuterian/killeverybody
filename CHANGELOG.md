# Changelog

앞으로 **바뀐 것만** 짧게 적습니다 (날짜 + 불릿).

## 2.0.0

- 마케팅 버전 **2.0.0**.
- README·SPEC에 영감 출처 명시: 키플러(kippler)의 Windows용 **다죽여**(AllKill) — [http://kippler.com/allkill/](http://kippler.com/allkill/).
- CI/Release: SPM `Sparkle.framework` 임베드는 `scripts/embed-sparkle-framework.sh` 빌드 페이즈로 처리; Xcode 사용자 스크립트 샌드박스 비활성화로 CI에서 경로 접근 가능. 스크립트 `outputPaths`는 SPM과 중복되어 제거. 빌드 번호 9.

## 1.3.0

- README 한국어·영어·일본어 분리 및 상호 링크(`README.md`, `README.en.md`, `README.ja.md`).
- 메인 UI를 **「다 죽일까요?」** 다이얼로그로 단순화(다죽이기 / 적당히 죽이기 / 종료, 확인 알림). 설정은 메뉴 ⌘,만.
- Sparkle: `Sparkle.framework`를 앱 번들에 Embed, 업데이터 초기화 시점 정리.

## 1.2.0

- Sparkle 자동 업데이트(피드: GitHub Release `appcast.xml`, 메뉴 「업데이트 확인…」).

## 1.1.1

- 앱 표시명·제품명·`.app` 이름 `killeverybody` 통일, 아이콘·표시명 Info 키 명시.
- 정책 보내기 기본 파일명 `killeverybody-policy.json`, `CHANGELOG.md` 추가.
