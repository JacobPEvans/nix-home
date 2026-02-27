# Ansible Development Shell
#
# Minimal Ansible-only environment for configuration management repositories.
# No Terraform/Packer overhead - focused on Ansible, linting, and testing.
#
# Usage:
#   nix develop
#   # or with direnv: echo "use flake" > .envrc && direnv allow

{
  description = "Ansible configuration management development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
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
            };
          }
        );
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # === Configuration Management ===
              ansible
              ansible-lint
              molecule

              # === Secrets Management ===
              sops
              age

              # === Python (Ansible dependencies) ===
              (python3.withPackages (
                ps: with ps; [
                  paramiko
                  jsondiff
                  pyyaml
                  jinja2
                ]
              ))

              # === Utilities ===
              jq
              yq
              pre-commit
            ];

            shellHook = ''
              if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
                echo "═══════════════════════════════════════════════════════════════"
                echo "Ansible Configuration Management Environment"
                echo "═══════════════════════════════════════════════════════════════"
                echo ""
                echo "Configuration Management:"
                echo "  - ansible: $(ansible --version 2>/dev/null | head -1)"
                echo "  - ansible-lint: $(ansible-lint --version 2>/dev/null)"
                echo "  - molecule: $(molecule --version 2>/dev/null)"
                echo ""
                echo "Secrets Management:"
                echo "  - sops: $(sops --version 2>/dev/null)"
                echo "  - age: $(age --version 2>/dev/null)"
                echo ""
                echo "Getting Started:"
                echo "  1. Install collections: ansible-galaxy install -r requirements.yml"
                echo "  2. Setup pre-commit: pre-commit install"
                echo "  3. Run playbook: ansible-playbook -i inventory/hosts.yml playbooks/site.yml"
                echo ""
              fi
            '';
          };
        }
      );
    };
}
