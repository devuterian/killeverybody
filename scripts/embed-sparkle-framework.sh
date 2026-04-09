#!/bin/sh
# SPM Sparkle을 앱 번들 Contents/Frameworks에 둔다.
set -euo pipefail

APP="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

if [ ! -d "${APP}" ]; then
  echo "::error::앱 번들이 아직 없습니다: ${APP}" >&2
  exit 1
fi

DEST="${APP}/Contents/Frameworks"

if [ -d "${DEST}/Sparkle.framework" ]; then
  echo "Sparkle.framework already in app bundle; skipping embed script."
  exit 0
fi

mkdir -p "${DEST}"

SRC=""

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

# Release 유니버설 등: BUILD_DIR 아래에서 검색 (스크립트 샌드박스는 프로젝트에서 끔)
if [ -z "${SRC}" ] && [ -n "${BUILD_DIR:-}" ]; then
  SRC=$(find "${BUILD_DIR}" -type d \( -name 'Sparkle.framework' -o -name 'Sparkle_*.framework' \) 2>/dev/null | grep '/PackageFrameworks/' | head -1 || true)
  [ -n "${SRC}" ] || SRC=$(find "${BUILD_DIR}" -type d \( -name 'Sparkle.framework' -o -name 'Sparkle_*.framework' \) 2>/dev/null | head -1 || true)
fi

if [ -z "${SRC}" ]; then
  echo "::error::Sparkle.framework를 찾지 못했습니다." >&2
  echo "BUILD_DIR=${BUILD_DIR:-}" >&2
  echo "BUILT_PRODUCTS_DIR=${BUILT_PRODUCTS_DIR}" >&2
  echo "TARGET_BUILD_DIR=${TARGET_BUILD_DIR:-}" >&2
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
