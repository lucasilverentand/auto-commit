#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  TMPDIR="$(mktemp -d)"
  REMOTE_REPO="$TMPDIR/remote.git"
  WORK_REPO="$TMPDIR/work"
  git init --bare "$REMOTE_REPO" >/dev/null
  git init "$WORK_REPO" >/dev/null
  git -C "$WORK_REPO" remote add origin "$REMOTE_REPO"
  git -C "$WORK_REPO" config user.name "Test"
  git -C "$WORK_REPO" config user.email "test@example.com"
  touch "$WORK_REPO/file1.txt"
  touch "$WORK_REPO/file2.txt"
  git -C "$WORK_REPO" add file1.txt file2.txt
  git -C "$WORK_REPO" commit -m "initial commit" >/dev/null
  git -C "$WORK_REPO" push -u origin master >/dev/null 2>&1
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "prints message when no changes" {
  run bash -c "cd \"$WORK_REPO\" && \"$REPO_ROOT/auto-commit.sh\""
  [ "$status" -eq 0 ]
  [ "$output" = "No changes to commit." ]
}

@test "commits changes with default message" {
  echo "update" >> "$WORK_REPO/file1.txt"
  run bash -c "cd \"$WORK_REPO\" && \"$REPO_ROOT/auto-commit.sh\""
  [ "$status" -eq 0 ]
  commit_msg="$(git -C "$WORK_REPO" log -1 --pretty=%B)"
  expected=$'chore: automated update\n\nCo-authored-by: Test <test@example.com>'
  [ "$commit_msg" = "$expected" ]
}

@test "uses provided commit message" {
  echo "update" >> "$WORK_REPO/file1.txt"
  run bash -c "cd \"$WORK_REPO\" && \"$REPO_ROOT/auto-commit.sh\" \"feat: custom\""
  [ "$status" -eq 0 ]
  commit_msg="$(git -C "$WORK_REPO" log -1 --pretty=%B)"
  expected=$'feat: custom\n\nCo-authored-by: Test <test@example.com>'
  [ "$commit_msg" = "$expected" ]
}

@test "respects FILTER variable" {
  echo "update1" >> "$WORK_REPO/file1.txt"
  echo "update2" >> "$WORK_REPO/file2.txt"
  run bash -c "cd \"$WORK_REPO\" && FILTER=\"file1.txt\" \"$REPO_ROOT/auto-commit.sh\""
  [ "$status" -eq 0 ]

  run git -C "$WORK_REPO" diff --quiet HEAD -- file1.txt
  [ "$status" -eq 0 ]

  run git -C "$WORK_REPO" diff --quiet HEAD -- file2.txt
  [ "$status" -eq 1 ]
}
