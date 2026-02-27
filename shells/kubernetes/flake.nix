# Kubernetes Development & Validation Shell
#
# Complete Kubernetes ecosystem: manifest validation, policy enforcement,
# linting, package management, orchestration, and local cluster testing.
#
# Usage:
#   nix develop
#   # or with direnv: echo "use flake" > .envrc && direnv allow

{
  description = "Kubernetes development, validation, and orchestration environment";

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
              # === Core CLI ===
              kubectl
              kubectx # includes kubens

              # === Package Management ===
              kubernetes-helm-wrapped
              helmfile
              kustomize
              helm-docs

              # === Validation & Linting ===
              kubeconform # schema-based manifest validation (kubeval successor)
              kube-linter # best-practices linting for k8s manifests
              conftest # policy testing with OPA/Rego
              pluto # detect deprecated API versions

              # === Terminal UI & Log Tailing ===
              k9s
              stern

              # === Local Cluster Testing ===
              kind # Kubernetes IN Docker

              # === Utilities ===
              git
              jq
              yq
            ];

            shellHook = ''
              if [ -z "''${DIRENV_IN_ENVRC:-}" ]; then
                echo "═══════════════════════════════════════════════════════════════"
                echo "Kubernetes Development & Validation Environment"
                echo "═══════════════════════════════════════════════════════════════"
                echo ""
                echo "Core CLI:"
                echo "  - kubectl:   $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1 || echo 'available')"
                echo "  - kubectx:   $(kubectx --version 2>/dev/null || echo 'available')"
                echo ""
                echo "Package Management:"
                echo "  - helm:      $(helm version --short 2>/dev/null || echo 'available')"
                echo "  - helmfile:  $(helmfile --version 2>/dev/null | head -1 || echo 'available')"
                echo "  - kustomize: $(kustomize version 2>/dev/null || echo 'available')"
                echo ""
                echo "Validation & Linting:"
                echo "  - kubeconform: $(kubeconform -v 2>/dev/null || echo 'available')"
                echo "  - kube-linter: $(kube-linter version 2>/dev/null || echo 'available')"
                echo "  - conftest:    $(conftest --version 2>/dev/null || echo 'available')"
                echo "  - pluto:       $(pluto version 2>/dev/null || echo 'available')"
                echo ""
                echo "Local Testing:"
                echo "  - kind:  $(kind --version 2>/dev/null || echo 'available')"
                echo ""
                echo "Getting Started:"
                echo "  Validate:      kubeconform -summary manifest.yaml"
                echo "  Lint:          kube-linter lint ."
                echo "  Test policies: conftest test manifest.yaml"
                echo "  Deprecations:  pluto detect-files -d ."
                echo "  Local cluster: kind create cluster && kubectl cluster-info"
                echo "  Manage UI:     k9s"
                echo ""
              fi
            '';
          };
        }
      );
    };
}
