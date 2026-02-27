# Python 3.14 Development Shell
#
# Bleeding-edge Python 3.14 with full dev tools.
# All packages installed via Nix - no pip available.
#
# Usage: nix develop or direnv (use flake)
#
# Included: pytest, ruff, mypy, black, coverage, ipython

{
  description = "Python 3.14 development environment (bleeding edge)";

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
            python = pyEnv.versions.py314;
            packages = pyEnv.packageSets.dev;
            name = "python314-dev";
            shellHookExtra = ''
              echo "Dev tools: pytest, ruff, mypy, black, coverage, ipython"
              echo ""
            '';
          };
        }
      );
    };
}
