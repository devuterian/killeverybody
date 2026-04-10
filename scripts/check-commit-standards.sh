#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <commit-message-file>" >&2
  exit 2
fi

msg_file=$1

if [ ! -f "$msg_file" ]; then
  echo "commit standards check failed: commit message file not found: $msg_file" >&2
  exit 2
fi

has_trailer() {
  key=$1
  grep -Eq "^$key: .+" "$msg_file"
}

trailer_value() {
  key=$1
  sed -n "s/^$key: //p" "$msg_file" | tail -n 1
}

is_exception_commit() {
  grep -Eqi '^(bootstrap|migration)(\b| exception\b)' "$msg_file" ||
    grep -Eqi '^exception: (bootstrap|migration)$' "$msg_file"
}

# 에이전트용 트레일러 대신, 일반 OSS/수동 커밋(Conventional·릴리즈·머지·짧은 명령형 제목)을 허용한다.
is_oss_style_commit() {
  printf '%s\n' "$subject" | grep -Eqi '^(revert: )?(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\([^)]*\))?!?: .+' && return 0
  printf '%s\n' "$subject" | grep -Eq '^Release [vV]?[0-9]+\.[0-9]+(\.[0-9]+)?(\s|$|:)' && return 0
  printf '%s\n' "$subject" | grep -Eqi '^release: .+' && return 0
  printf '%s\n' "$subject" | grep -Eq '^Merge (pull request |branch .+ from )' && return 0
  printf '%s\n' "$subject" | grep -Eqi '^(fix|update|add|remove|bump|revert|docs|chore|feat|build|ci|style|refactor|perf|test)\b.+' && return 0
  return 1
}

fail() {
  echo "commit standards check failed: $1" >&2
  echo >&2
  echo "Use either OSS-style subject (e.g. fix: …, Release v1.2.3 / Release 1.2.3, Fix typo in README) or agent trailers:" >&2
  echo "  project: <project-id>" >&2
  echo "  agent: <agent-id>" >&2
  echo "  role: orchestrator|worker|subagent|operator" >&2
  echo "  artifacts: <artifact-id>[, <artifact-id>...]" >&2
  echo >&2
  echo "Bootstrap or migration exceptions must be explicit in the commit message." >&2
  exit 1
}

subject=$(sed -n '1p' "$msg_file")
[ -n "$subject" ] || fail "subject line is empty"

if is_exception_commit; then
  exit 0
fi

if is_oss_style_commit; then
  exit 0
fi

has_trailer "project" || fail "missing trailer: project"
has_trailer "agent" || fail "missing trailer: agent"
has_trailer "role" || fail "missing trailer: role"
has_trailer "artifacts" || fail "missing trailer: artifacts"

role=$(trailer_value "role")
case "$role" in
  orchestrator|worker|subagent|operator) ;;
  *) fail "invalid role trailer: $role" ;;
esac

artifacts=$(trailer_value "artifacts")
[ -n "$artifacts" ] || fail "artifacts trailer is empty"

echo "$artifacts" | grep -Eq '^[A-Z]{3}-[0-9]{8}-[0-9]{3}(, [A-Z]{3}-[0-9]{8}-[0-9]{3})*$' ||
  fail "artifacts trailer must be a comma-separated list like ART-YYYYMMDD-NNN"
