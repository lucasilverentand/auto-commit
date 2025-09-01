# Auto Commit Action

Automatically commit changes made during a GitHub Actions workflow and push them back to the repository.

## Features

- Detects modified files during a workflow run.
- Commits them with a customizable commit message.
- Pushes the commit to the branch that triggered the workflow.
- Co-authors the commit with the author of the last commit.
- Skips committing when no matching changes are found.
- Restricts commits to an optional glob filter to avoid unintended files.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0
  # ... other steps that make changes ...
  - uses: ./
    with:
      commit-message: "chore: update files"
      filter: |
        docs/**
        *.md
```

By default, the commit message is `chore: automated update`.
If `filter` is empty or not provided, all changes are considered.
