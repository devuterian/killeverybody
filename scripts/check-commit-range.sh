#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <base> <head>" >&2
  exit 2
fi

base=$1
head=$2

repo_root=$(cd "$(dirname "$0")/.." && pwd)
checker="$repo_root/scripts/check-commit-standards.sh"

# GitHub push 이벤트에서 최초 푸시·일부 태그 푸시는 before 가 40자 0 이라 범위가 무효다.
if [ "$base" = "0000000000000000000000000000000000000000" ]; then
  commits=$(git -C "$repo_root" rev-list "$head")
else
  commits=$(git -C "$repo_root" rev-list "$base..$head")
fi

if [ -z "$commits" ]; then
  echo "No commits to check in range $base..$head"
  exit 0
fi

for commit in $commits; do
  tmp=$(mktemp)
  git -C "$repo_root" log -1 --format=%B "$commit" > "$tmp"
  if ! "$checker" "$tmp"; then
    echo >&2
    echo "Offending commit: $commit" >&2
    rm -f "$tmp"
    exit 1
  fi
  rm -f "$tmp"
done

echo "Commit standards passed for range $base..$head"
