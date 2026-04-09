#!/bin/sh
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/KillEverybodyApp/KillEverybodyApp"
SDK=$(xcrun --show-sdk-path --sdk macosx 2>/dev/null) || {
  echo "smoke-check: macOS SDK를 찾을 수 없습니다." >&2
  exit 1
}
cd "$SRC"
echo "smoke-check: swiftc -typecheck (arm64-apple-macosx13.0) …"
xcrun swiftc -typecheck \
  -sdk "$SDK" \
  -target arm64-apple-macosx13.0 \
  KillEverybodyAppApp.swift \
  ContentView.swift \
  SettingsStore.swift \
  DenyList.swift \
  PlistHelpers.swift \
  ProcessEnumerator.swift \
  KillExecutor.swift \
  MenubarProtectionPresets.swift \
  PolicyDocument.swift
echo "smoke-check: OK"
