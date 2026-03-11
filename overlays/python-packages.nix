# Python Package Overlays
#
# Overrides for Python packages that are outdated in nixpkgs.
# Package definitions live in packages/ for nix-update compatibility.

final: prev: {
  python3 = prev.python3.override {
    packageOverrides = _python-final: python-prev: {
      grip = prev.callPackage ../packages/grip.nix {
        # Pass the unoverridden Python packages so grip.nix can inherit deps
        # from nixpkgs grip without creating a self-referential cycle.
        python3Packages = python-prev;
      };
    };
  };

  python3Packages = final.python3.pkgs;
}
