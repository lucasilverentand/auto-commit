#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_REPO="$(mktemp -d)"
trap 'rm -rf "$TMP_REPO"' EXIT

cd "$TMP_REPO"

git init >/dev/null
git config user.name "Test"
git config user.email "test@example.com"
touch file.txt
git add file.txt
git commit -m "initial commit" >/dev/null

output="$($REPO_ROOT/auto-commit.sh)"
if [ "$output" != "No changes to commit." ]; then
  echo "Unexpected output: $output" >&2
  exit 1
fi
