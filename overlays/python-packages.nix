# Python Package Overlays
#
# Overrides for Python packages that are outdated in nixpkgs.
# Package definitions live in packages/ for nix-update compatibility.

final: prev: {
  python3 = prev.python3.override {
    packageOverrides = python-final: _python-prev: {
      grip = python-final.callPackage ../packages/grip.nix { };
    };
  };

  python3Packages = final.python3.pkgs;

  python314 = prev.python314.override {
    packageOverrides = python-final: _python-prev: {
      grip = python-final.callPackage ../packages/grip.nix { };
    };
  };

  python314Packages = final.python314.pkgs;
}
