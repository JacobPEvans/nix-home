#!/usr/bin/env bash
# Detect if a PR is a dependency-only update from the Renovate bot.
# Expects AUTHOR and COMMIT_MSG environment variables.
# Outputs: is-deps-only=true|false to $GITHUB_OUTPUT
set -euo pipefail

if [[ "${AUTHOR:-}" == "jacobpevans-github-actions"* && "${COMMIT_MSG:-}" == chore\(deps\)* ]]; then
  echo "is-deps-only=true" >> "$GITHUB_OUTPUT"
else
  echo "is-deps-only=false" >> "$GITHUB_OUTPUT"
fi
