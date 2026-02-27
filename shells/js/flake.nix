# JavaScript/Node.js Development Shell
#
# Node.js environment with npm and common tools.
#
# Usage:
#   1. Copy this file to your project
#   2. Create .envrc with "use flake"
#   3. Run: direnv allow
#
# Or manually: nix develop
#
# Note: Project dependencies still use package.json/npm install

{
  description = "Node.js development environment";

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
              # Node.js LTS (nixpkgs default)
              nodejs

              # Package managers (npm included with nodejs)
              yarn
              pnpm

              # Development tools
              nodePackages.typescript
              # TypeScript language server (for IDE integration)
              nodePackages.typescript-language-server

              # Add more as needed:
              # nodePackages.eslint
              # nodePackages.prettier
            ];

            shellHook = ''
              echo "Node.js $(node --version) environment ready"
              echo "  - npm, yarn, pnpm"
              echo "  - TypeScript + LSP"
            '';
          };
        }
      );
    };
}
