# Image Building & Configuration Development Shell
#
# Complete image building environment for Packer with Ansible for
# configuration management, supporting multi-platform builds.
#
# Usage:
#   nix develop
#   # or with direnv: echo "use flake" > .envrc && direnv allow

{
  description = "Image building and configuration management development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-config.url = "path:../..";
  };

  outputs =
    {
      nixpkgs,
      nix-config,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true; # Packer uses BSL license
            };
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        let
          pythonEnvs = import "${nix-config}/lib/python-environments.nix" { inherit pkgs; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # === Image Building ===
              packer

              # === Configuration Management ===
              ansible
              ansible-lint
              molecule
              (python3.withPackages pythonEnvs.packageSets.ansible)

              # === Development ===
              git
              jq
              yq
            ];

            shellHook = ''
              {
                echo "═══════════════════════════════════════════════════════════════"
                echo "Image Building & Configuration Management Environment"
                echo "═══════════════════════════════════════════════════════════════"
                echo ""
                echo "Image Building:"
                echo "  - packer: $(packer version 2>/dev/null || echo 'not available')"
                echo ""
                echo "Configuration Management:"
                echo "  - ansible: $(ansible --version 2>/dev/null | head -1)"
                echo "  - molecule: $(molecule --version 2>/dev/null)"
                echo ""
                echo "Getting Started:"
                echo "  1. Write Packer templates in HCL2 format"
                echo "  2. Build with: packer build <template.hcl>"
                echo "  3. Test configurations with: molecule test"
                echo ""
              }
            '';
          };
        }
      );
    };
}
