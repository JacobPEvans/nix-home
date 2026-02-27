# Python 3.12 Development Shell
#
# Full dev environment with testing, linting, formatting, type checking.
# All packages installed via Nix - no pip available.
#
# Usage: nix develop or direnv (use flake)
#
# Included: pytest, ruff, mypy, black, coverage, ipython

{
  description = "Python 3.12 development environment";

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
            python = pyEnv.versions.py312;
            packages = pyEnv.packageSets.dev;
            name = "python312-dev";
            shellHookExtra = ''
              echo "Dev tools: pytest, ruff, mypy, black, coverage, ipython"
              echo ""
            '';
          };
        }
      );
    };
}
