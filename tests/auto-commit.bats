#!/usr/bin/env bats

setup() {
  TMP_REPO="$(mktemp -d)"
  cd "$TMP_REPO"
  git init >/dev/null
  git config user.name "Test"
  git config user.email "test@example.com"
  touch file.txt
  git add file.txt
  git commit -m "initial commit" >/dev/null
}

teardown() {
  rm -rf "$TMP_REPO"
}

@test "does nothing when no changes" {
  run "$BATS_TEST_DIRNAME/../auto-commit.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "No changes to commit." ]
}
