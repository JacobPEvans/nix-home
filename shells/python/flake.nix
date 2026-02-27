# Python Development Shell
#
# Basic Python development environment with pip and venv support.
#
# Usage:
#   1. Copy this file to your project
#   2. Create .envrc with "use flake"
#   3. Run: direnv allow
#
# Or manually: nix develop

{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      # Support multiple systems
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs systems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Python 3.12 with common packages
              (python312.withPackages (
                ps: with ps; [
                  pip
                  virtualenv
                  # Add project-specific packages here:
                  # requests
                  # pytest
                ]
              ))
            ];

            shellHook = ''
              echo "$(python --version) environment ready"
            '';
          };
        }
      );
    };
}
