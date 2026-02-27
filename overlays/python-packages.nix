# Python Package Overlays
#
# Overrides for Python packages that are outdated in nixpkgs.
# This allows us to use newer versions without waiting for nixpkgs updates.
#
# How overlays work:
# - `final` = the final package set (after all overlays applied)
# - `prev` = the previous package set (before this overlay)
# - We return an attrset of packages to override
#
# To add a new override:
# 1. Find the package hash: nix-prefetch-url <url>
# 2. Convert to SRI: nix hash convert --hash-algo sha256 <hash>
# 3. Add override below following the pattern

final: prev: {
  python3 = prev.python3.override {
    packageOverrides = _python-final: python-prev: {
      # grip: GitHub Markdown previewer
      # nixpkgs has 4.6.1 (released 2022-03-13), updating to 4.6.2 (released 2023-10-22)
      # 4.6.2 includes the Werkzeug 3 charset fix (see https://github.com/joeyespo/grip/pull/349)
      # so we remove the nixpkgs patch
      # Changelog: https://github.com/joeyespo/grip/blob/master/CHANGES.md
      grip = python-prev.grip.overridePythonAttrs (_old: {
        version = "4.6.2";
        src = prev.fetchPypi {
          pname = "grip";
          version = "4.6.2";
          hash = "sha256-PPbc4KoG7dZjF2kUBpr4PxncuQ86nEAScaz6cYcvjOM=";
        };
        # Remove patches - 4.6.2 already includes the charset fix
        patches = [ ];
        # Skip tests - test helpers not in sdist, upstream tests pass
        doCheck = false;
      });
    };
  };

  python3Packages = final.python3.pkgs;
}
