#!/usr/bin/env bash
set -euo pipefail

COMMIT_MESSAGE=${1:-"chore: automated update"}

# Build an array of file patterns from FILTER env (newline separated)
FILTERS=()
if [[ -n "${FILTER:-}" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && FILTERS+=("$line")
  done <<< "${FILTER}"
fi
if [[ ${#FILTERS[@]} -eq 0 ]]; then
  FILTERS=(".")
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

if [[ -n $(git status --porcelain -- "${FILTERS[@]}") ]]; then
  git add -- "${FILTERS[@]}"
  last_author=$(git log -1 --pretty=format:'%an <%ae>')
  git commit -m "$COMMIT_MESSAGE"$'\n\n'"Co-authored-by: $last_author"
  git push
else
  echo "No changes to commit."
fi
