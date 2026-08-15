#!/bin/sh
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/KillEverybodyApp/KillEverybodyApp"
SDK=$(xcrun --show-sdk-path --sdk macosx 2>/dev/null) || {
  echo "smoke-check: macOS SDK를 찾을 수 없습니다." >&2
  exit 1
}
cd "$SRC"
if grep -q 'URL(fileURLWithPath: "/usr/bin/sfltool")' ApplicationCatalog.swift; then
  echo "smoke-check: 로그인 앱 조회가 권한을 요구하는 sfltool을 사용합니다." >&2
  exit 1
fi
test "$(plutil -extract SUEnableAutomaticChecks raw Info.plist)" = "true"
test "$(plutil -extract SUAutomaticallyUpdate raw Info.plist)" = "true"
echo "smoke-check: swiftc -typecheck (arm64-apple-macosx13.0) …"
# KillEverybodyAppApp / AppDelegate는 Sparkle·Carbon 의존으로 여기서는 제외합니다. 전체 빌드는 Xcode에서 하세요.
xcrun swiftc -typecheck \
  -sdk "$SDK" \
  -target arm64-apple-macosx13.0 \
  KillModalFlow.swift \
  ContentView.swift \
  Localization.swift \
  ApplicationCatalog.swift \
  SettingsStore.swift \
  DenyList.swift \
  PlistHelpers.swift \
  ProcessEnumerator.swift \
  KillExecutor.swift \
  LaunchAgentSuppressor.swift \
  MenubarProtectionPresets.swift \
  PolicyDocument.swift
xcrun swiftc -typecheck \
  -sdk "$SDK" \
  -target arm64-apple-macosx13.0 \
  ../KillEverybodyCLI/KillEverybodyCLI.swift \
  DenyList.swift \
  PlistHelpers.swift \
  ProcessEnumerator.swift \
  KillExecutor.swift \
  LaunchAgentSuppressor.swift \
  MenubarProtectionPresets.swift \
  PolicyDocument.swift
echo "smoke-check: OK"
