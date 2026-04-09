#!/bin/sh
# Xcode SPM은 Sparkle.framework를 Products/PackageFrameworks 등에 두는데,
# 수동 PBXCopyFilesBuildPhase(productRef)는 Release/Sparkle 경로를 기대해 CI에서 실패할 수 있다.
# 이 스크립트는 빌드 산출물에서 Sparkle.framework를 찾아 앱 번들에 복사한다.
set -euo pipefail

APP="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
DEST="${APP}/Contents/Frameworks"
mkdir -p "${DEST}"

find_sparkle() {
  # 가장 흔한 경로 (Xcode 15+)
  if [ -d "${BUILT_PRODUCTS_DIR}/PackageFrameworks/Sparkle.framework" ]; then
    echo "${BUILT_PRODUCTS_DIR}/PackageFrameworks/Sparkle.framework"
    return 0
  fi
  # 그 외: 빌드 트리에서 검색
  f=$(find "${BUILD_DIR}" -name "Sparkle.framework" -type d 2>/dev/null | head -1 || true)
  if [ -n "${f}" ]; then
    echo "${f}"
    return 0
  fi
  return 1
}

if ! SRC=$(find_sparkle); then
  echo "::error::Sparkle.framework를 찾지 못했습니다. BUILT_PRODUCTS_DIR=${BUILT_PRODUCTS_DIR}" >&2
  find "${BUILD_DIR:-.}" -name "Sparkle.framework" -type d 2>/dev/null | head -20 >&2 || true
  exit 1
fi

rm -rf "${DEST}/Sparkle.framework"
ditto "${SRC}" "${DEST}/Sparkle.framework"

# 서명 없는 CI 빌드에서는 임시 서명으로 번들 로드 가능하게 한다.
if [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ] || [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  codesign --force --sign - "${DEST}/Sparkle.framework" 2>/dev/null || true
else
  codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" "${DEST}/Sparkle.framework" || true
fi

echo "Embedded Sparkle.framework from ${SRC}"
