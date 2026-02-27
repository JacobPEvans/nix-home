# Python 3.10 Development Shell
#
# Minimal Python 3.10 environment for older compatibility testing.
# All packages installed via Nix - no pip available.
#
# Usage: nix develop or direnv (use flake)

{
  description = "Python 3.10 minimal environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          pyEnv = import ../../lib/python-environments.nix { inherit pkgs; };
        in
        {
          default = pyEnv.mkDevShell {
            python = pyEnv.versions.py310;
            packages = pyEnv.packageSets.minimal;
            name = "python310-minimal";
          };
        }
      );
    };
}
