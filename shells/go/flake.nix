# Go Development Shell
#
# Go environment with language server and debugging tools.
#
# Usage:
#   1. Copy this file to your project
#   2. Create .envrc with "use flake"
#   3. Run: direnv allow
#
# Or manually: nix develop

{
  description = "Go development environment";

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
        f: nixpkgs.lib.genAttrs systems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Go compiler and tools
              go

              # Language server (for IDE integration)
              gopls

              # Debugging
              delve

              # Linting and formatting (included in go, but explicit for clarity)
              # go fmt, go vet are built-in

              # Additional tools as needed:
              # golangci-lint
              # gotools
            ];

            shellHook = ''
              echo "$(go version) environment ready"
              echo "  - gopls (language server)"
              echo "  - delve (debugger)"
            '';
          };
        }
      );
    };
}
