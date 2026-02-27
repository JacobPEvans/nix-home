# Infrastructure Automation Development Shell
#
# Complete infrastructure-as-code environment combining Packer for image building
# with Terraform for infrastructure provisioning, including Ansible for
# configuration management and security scanning tools.
#
# Usage:
#   nix develop
#   # or with direnv: echo "use flake" > .envrc && direnv allow

{
  description = "Infrastructure automation with Packer and Terraform/Terragrunt development environment";

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
              config.allowUnfree = true; # Packer & Terraform use BSL license
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
              # === Image Building ===
              packer

              # === Infrastructure as Code ===
              terraform
              terragrunt
              opentofu
              terraform-docs
              tflint

              # === Configuration Management ===
              ansible
              ansible-lint
              molecule

              # === Security & Compliance ===
              checkov
              terrascan
              tfsec
              trivy

              # === Secrets Management ===
              sops
              age

              # === Cloud & Development ===
              awscli2
              (python3.withPackages (
                ps: with ps; [
                  paramiko
                  jsondiff
                  pyyaml
                  jinja2
                ]
              ))
              git

              # === Utilities ===
              jq
              yq
              pre-commit
            ];

            shellHook = ''
              if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
                echo "═══════════════════════════════════════════════════════════════"
                echo "Infrastructure Automation Development Environment"
                echo "═══════════════════════════════════════════════════════════════"
                echo ""
                echo "Image Building:"
                echo "  - packer: $(packer version 2>/dev/null || echo 'not available')"
                echo ""
                echo "Infrastructure as Code:"
                echo "  - terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1)"
                echo "  - terragrunt: $(terragrunt --version 2>/dev/null)"
                echo "  - opentofu: $(tofu version 2>/dev/null | head -1)"
                echo ""
                echo "Configuration Management:"
                echo "  - ansible: $(ansible --version 2>/dev/null | head -1)"
                echo "  - molecule: $(molecule --version 2>/dev/null)"
                echo ""
                echo "Security & Compliance:"
                echo "  - checkov: $(checkov --version 2>/dev/null)"
                echo "  - terrascan: $(terrascan version 2>/dev/null | head -1)"
                echo "  - tfsec: $(tfsec --version 2>/dev/null)"
                echo "  - trivy: $(trivy --version 2>/dev/null | head -1)"
                echo ""
                echo "Secrets Management:"
                echo "  - sops: $(sops --version 2>/dev/null)"
                echo "  - age: $(age --version 2>/dev/null)"
                echo ""
                echo "Cloud:"
                echo "  - aws-cli: $(aws --version 2>/dev/null)"
                echo ""
                echo "Workflows:"
                echo "  Image + Provisioning:"
                echo "    1. Build images: packer build <template.hcl>"
                echo "    2. Deploy infrastructure: terragrunt apply"
                echo "    3. Configure systems: ansible-playbook <playbook.yml>"
                echo ""
                echo "  Infrastructure Only:"
                echo "    1. Initialize: terragrunt init"
                echo "    2. Setup pre-commit: pre-commit install"
                echo "    3. Deploy: terragrunt apply"
                echo ""
              fi
            '';
          };
        }
      );
    };
}
