#!/bin/sh
# Xcode SPM은 Sparkle을 PackageFrameworks 아래 .framework로 둔다.
# 제품명이 Sparkle.framework 또는 Sparkle_Sparkle.framework 등일 수 있다.
set -euo pipefail

APP="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
DEST="${APP}/Contents/Frameworks"
mkdir -p "${DEST}"

SRC=""

# 1) 고정 후보 (BUILT_PRODUCTS_DIR == TARGET_BUILD_DIR 인 경우가 많음)
for d in \
  "${BUILT_PRODUCTS_DIR}/PackageFrameworks/Sparkle.framework" \
  "${CONFIGURATION_BUILD_DIR}/PackageFrameworks/Sparkle.framework" \
  "${TARGET_BUILD_DIR}/PackageFrameworks/Sparkle.framework"
do
  if [ -d "${d}" ]; then
    SRC="${d}"
    break
  fi
done

# 2) PackageFrameworks 안에서 Sparkle로 시작하는 .framework (SPM 모듈 접두사 대응)
if [ -z "${SRC}" ]; then
  for base in "${BUILT_PRODUCTS_DIR}" "${CONFIGURATION_BUILD_DIR}" "${TARGET_BUILD_DIR}"; do
    [ -n "${base}" ] || continue
    pf="${base}/PackageFrameworks"
    [ -d "${pf}" ] || continue
    for d in "${pf}/Sparkle.framework" "${pf}/"Sparkle_*.framework; do
      if [ -d "${d}" ]; then
        SRC="${d}"
        break 2
      fi
    done
  done
fi

# 3) OBJECT_FILE_DIR → Build/Products/<Configuration>/PackageFrameworks
#    (스크립트 시점의 OBJECT_FILE_DIR 깊이가 환경마다 달라 4단·6단 모두 시도)
if [ -z "${SRC}" ] && [ -n "${OBJECT_FILE_DIR:-}" ]; then
  for rel in \
    "${OBJECT_FILE_DIR}/../../../../Products/${CONFIGURATION}/PackageFrameworks" \
    "${OBJECT_FILE_DIR}/../../../../../../Products/${CONFIGURATION}/PackageFrameworks"
  do
    for d in "${rel}/Sparkle.framework" "${rel}/"Sparkle_*.framework; do
      if [ -d "${d}" ]; then
        SRC="${d}"
        break 2
      fi
    done
  done
fi

if [ -z "${SRC}" ]; then
  echo "::error::Sparkle.framework를 찾지 못했습니다." >&2
  echo "BUILT_PRODUCTS_DIR=${BUILT_PRODUCTS_DIR}" >&2
  echo "CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_DIR:-}" >&2
  echo "TARGET_BUILD_DIR=${TARGET_BUILD_DIR:-}" >&2
  echo "OBJECT_FILE_DIR=${OBJECT_FILE_DIR:-}" >&2
  echo "CONFIGURATION=${CONFIGURATION:-}" >&2
  for base in "${BUILT_PRODUCTS_DIR}" "${CONFIGURATION_BUILD_DIR}"; do
    echo "--- ls ${base} ---" >&2
    ls -la "${base}" 2>&1 >&2 || true
    echo "--- ls ${base}/PackageFrameworks ---" >&2
    ls -la "${base}/PackageFrameworks" 2>&1 >&2 || true
  done
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
