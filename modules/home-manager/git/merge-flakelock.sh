#!/usr/bin/env bash
# Git merge driver for flake.lock
#
# Instead of 3-way merge, regenerate the lock file.
# Called by git with: %O (ancestor) %A (current) %B (other)
#
# Usage in .gitattributes:
#   flake.lock merge=flakelock
#
# Usage in git config:
#   [merge "flakelock"]
#     name = Regenerate flake.lock
#     driver = ~/.local/bin/git-merge-flakelock %O %A %B

set -euo pipefail

# Arguments from git - only %A (current) is needed; %O and %B are ignored
# The regeneration strategy doesn't use ancestor or other versions
CURRENT="$2"   # %A - current version (ours) - we write result here

# Regenerate flake.lock without updating inputs
# Uses --no-update-lock-file to preserve current input versions
LOCK_DIR="$(dirname "$CURRENT")"

# Ensure we're operating in a directory that contains a flake.nix
if [ ! -f "$LOCK_DIR/flake.nix" ]; then
    echo "Warning: flake.nix not found in $LOCK_DIR, keeping current flake.lock" >&2
    exit 0
fi

(
    cd "$LOCK_DIR"

    if nix flake lock --no-update-lock-file 2>/dev/null; then
        # Copy regenerated lock to the merge result
        cp flake.lock "$CURRENT"
        exit 0
    else
        # If regeneration fails, accept current version and let user handle it
        echo "Warning: flake.lock regeneration failed, keeping current version" >&2
        exit 0
    fi
)
