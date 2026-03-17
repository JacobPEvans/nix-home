# Python Package Overlays
#
# Overrides for Python packages that are outdated in nixpkgs.
# Package definitions live in packages/ for nix-update compatibility.
#
# NOTE: python3 cannot be overridden at the overlay level on Darwin because
# it is used by stdenv bootstrapping (AvailabilityVersions). Overriding it
# triggers infinite recursion in the stdenv boot chain. Instead, we only
# override python314/python314Packages and reference python314 explicitly.

final: prev:
let
  gripOverride = python-final: _python-prev: {
    grip = python-final.callPackage ../packages/grip.nix { };
  };
in
{
  # Override python314 with the grip package.
  # Consumers should reference python314 explicitly (not python3).
  python314 = prev.python314.override {
    packageOverrides = gripOverride;
  };
  python314Packages = final.python314.pkgs;
}
