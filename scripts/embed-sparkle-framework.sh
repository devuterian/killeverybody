#!/bin/sh
# Xcode SPM은 Sparkle.framework를 PackageFrameworks에 둔다.
# find 등은 Xcode 사용자 스크립트 샌드박스에서 막힐 수 있어, 고정 경로만 검사한다.
# (CI에서는 프로젝트에 ENABLE_USER_SCRIPT_SANDBOXING=NO 권장.)
set -euo pipefail

APP="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
DEST="${APP}/Contents/Frameworks"
mkdir -p "${DEST}"

SRC=""
for d in \
  "${BUILT_PRODUCTS_DIR}/PackageFrameworks/Sparkle.framework" \
  "${CONFIGURATION_BUILD_DIR}/PackageFrameworks/Sparkle.framework"
do
  if [ -d "${d}" ]; then
    SRC="${d}"
    break
  fi
done

if [ -z "${SRC}" ]; then
  echo "::error::Sparkle.framework를 찾지 못했습니다." >&2
  echo "BUILT_PRODUCTS_DIR=${BUILT_PRODUCTS_DIR}" >&2
  echo "CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_DIR:-}" >&2
  exit 1
fi

rm -rf "${DEST}/Sparkle.framework"
ditto "${SRC}" "${DEST}/Sparkle.framework"

if [ "${CODE_SIGNING_ALLOWED:-YES}" = "NO" ] || [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  codesign --force --sign - "${DEST}/Sparkle.framework" 2>/dev/null || true
else
  codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" "${DEST}/Sparkle.framework" || true
fi

echo "Embedded Sparkle.framework from ${SRC}"
