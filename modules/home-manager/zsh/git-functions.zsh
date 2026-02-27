# Git utility functions

# gw-a - Create worktree with new branch and change directory into it
# Usage: gw-a <branch-name>
# Example: gw-a feat/my-feature
#
# Works with bare repo structure:
#   ~/git/<repo>/       (bare repo)
#   ├── main/           (worktree)
#   ├── feat/branch/    (worktree)
#
# Creates a new worktree at <repo-root>/<branch-name>/ (as a sibling of the current worktree) from origin/main
gw-a() {
  set -e

  if [[ -z "$1" ]]; then
    echo "Usage: gw-a <branch-name>" >&2
    echo "Example: gw-a feat/my-feature" >&2
    return 1
  fi

  local branch="$1"

  # Validate branch name: no leading slash, no path traversal
  if [[ "$branch" =~ ^/ ]] || [[ "$branch" =~ \.\. ]]; then
    echo "error: Invalid branch name. Branch name must not start with '/' or contain '..'." >&2
    return 1
  fi

  # Find the git common directory (shared by all worktrees)
  local git_common_dir
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

  if [[ -z "$git_common_dir" || "$git_common_dir" == ".git" ]]; then
    echo "error: Not in a worktree-based repo. Use from within an existing worktree." >&2
    return 1
  fi

  # For bare repos, the common dir IS the bare repo
  # Navigate to the parent of .git (or the bare repo itself)
  local repo_root
  repo_root=$(dirname "$git_common_dir")

  # Ensure we have latest from origin
  git fetch origin || {
    echo "error: git fetch origin failed" >&2
    return 1
  }

  # Add worktree with new branch tracking origin/main
  git worktree add "$repo_root/$branch" -b "$branch" origin/main || {
    echo "error: git worktree add failed" >&2
    return 1
  }

  # Change into the new worktree
  cd "$repo_root/$branch"
}
