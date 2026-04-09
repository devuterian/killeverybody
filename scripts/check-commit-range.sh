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

# GitHub 태그 force-push 시 event.before 가 annotated tag 객체 SHA일 수 있다.
# rev-list A..B 는 커밋만 허용하므로 ^{commit} 으로 벗긴다.
peel_commit() {
  git -C "$repo_root" rev-parse "$1^{commit}"
}

# GitHub push 이벤트에서 최초 푸시·일부 태그 푸시는 before 가 40자 0 이라 범위가 무효다.
# 전체 히스토리를 돌리면 과거 커밋까지 검사해 항상 실패할 수 있으므로, 팁 커밋만 검사한다.
if [ "$base" = "0000000000000000000000000000000000000000" ]; then
  commits=$(peel_commit "$head")
else
  commits=$(git -C "$repo_root" rev-list "$(peel_commit "$base")..$(peel_commit "$head")")
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
