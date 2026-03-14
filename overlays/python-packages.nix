# Python Package Overlays
#
# Overrides for Python packages that are outdated in nixpkgs.
# Package definitions live in packages/ for nix-update compatibility.

final: prev: {
  # Default python3 → Python 3.14
  # All python3.withPackages / python3Packages usage gets 3.14 automatically.
  python3 = prev.python314.override {
    packageOverrides = python-final: _python-prev: {
      grip = python-final.callPackage ../packages/grip.nix { };
    };
  };

  python3Packages = final.python3.pkgs;
}
