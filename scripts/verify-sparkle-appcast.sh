#!/bin/sh
# 릴리스 appcast에 Sparkle EdDSA 서명이 있는지 확인합니다. (CONTRIBUTING Sparkle 절 보조)
set -eu
URL="${1:-https://github.com/devuterian/killeverybody/releases/latest/download/appcast.xml}"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if ! curl -fsSL "$URL" -o "$tmp"; then
  echo "verify-sparkle-appcast: 다운로드 실패: $URL" >&2
  exit 1
fi
if ! grep -q 'sparkle:edSignature="' "$tmp"; then
  echo "verify-sparkle-appcast: enclosure에 sparkle:edSignature가 없습니다." >&2
  exit 1
fi
if ! grep -q 'length="' "$tmp"; then
  echo "verify-sparkle-appcast: enclosure에 length가 없습니다." >&2
  exit 1
fi
echo "verify-sparkle-appcast: OK ($URL)"
