#!/usr/bin/env bash
# Update grip Python package version and hash in overlays/python-packages.nix
#
# Usage:
#   scripts/update-grip.sh           # Preview changes (dry run)
#   scripts/update-grip.sh --apply   # Apply changes to overlay

set -euo pipefail

APPLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

OVERLAY_FILE="$(dirname "$0")/../overlays/python-packages.nix"

echo "Fetching latest grip version from PyPI..."
PYPI_DATA=$(curl -fsSL "https://pypi.org/pypi/grip/json")
VERSION=$(printf '%s' "$PYPI_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['info']['version'])")
echo "Latest version: $VERSION"

CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$OVERLAY_FILE" | head -1)
echo "Current version: $CURRENT_VERSION"

if [ "$VERSION" = "$CURRENT_VERSION" ]; then
  echo "Already at latest version $VERSION — no update needed."
  exit 0
fi

# Get sdist URL from PyPI JSON
URL=$(printf '%s' "$PYPI_DATA" | python3 -c "
import json, sys
data = json.load(sys.stdin)
urls = data['releases']['$VERSION']
sdist = next(u for u in urls if u['packagetype'] == 'sdist')
print(sdist['url'])
")
echo "Fetching hash for: $URL"
HASH=$(nix store prefetch-file --hash-type sha256 "$URL" 2>/dev/null \
  | grep -o 'sha256-[A-Za-z0-9+/=]*' \
  || nix-prefetch-url "$URL" 2>/dev/null | xargs -I{} nix hash convert --to sri --hash-algo sha256 {})

echo ""
echo "Changes:"
echo "  version: $CURRENT_VERSION -> $VERSION"
echo "  hash:    $HASH"

if [ "$APPLY" = true ]; then
  # Portable in-place sed
  if sed --version 2>&1 | grep -q 'GNU sed'; then
    SED_I() { sed -i "$@"; }
  else
    SED_I() { sed -i '' "$@"; }
  fi

  # Update both version occurrences (appears twice in overridePythonAttrs block)
  SED_I "s/version = \"${CURRENT_VERSION}\"/version = \"${VERSION}\"/g" "$OVERLAY_FILE"
  SED_I "s|hash = \"sha256-[^\"]*\"|hash = \"${HASH}\"|" "$OVERLAY_FILE"
  echo "Applied changes to $OVERLAY_FILE"
else
  echo ""
  echo "Dry run. Pass --apply to update $OVERLAY_FILE"
fi
