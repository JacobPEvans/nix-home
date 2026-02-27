# PowerShell Development Shell
#
# Cross-platform PowerShell 7.x environment for scripting and automation.
#
# Usage:
#   1. Copy this file to your project
#   2. Create .envrc with "use flake"
#   3. Run: direnv allow
#
# Or manually: nix develop

{
  description = "PowerShell 7.x development environment for scripting";

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
              # === Core ===
              powershell

              # === Development ===
              dotnet-sdk
              git

              # === Utilities ===
              jq
              yq
              curl
            ];

            shellHook = ''
              {
                echo "═══════════════════════════════════════════════════════════════"
                echo "PowerShell Development Environment"
                echo "═══════════════════════════════════════════════════════════════"
                echo ""
                echo "Core:"
                echo "  - PowerShell: $(pwsh --version 2>/dev/null | cut -d' ' -f2)"
                echo "  - .NET SDK: $(dotnet --version 2>/dev/null)"
                echo ""
                echo "Utilities:"
                echo "  - jq: $(jq --version 2>/dev/null | cut -d'-' -f2)"
                echo "  - yq: $(yq --version 2>/dev/null | cut -d' ' -f2)"
                echo ""
                echo "Getting Started:"
                echo "  1. Enter PowerShell: pwsh"
                echo "  2. Install modules: Install-Module -Name <module> -Scope CurrentUser"
                echo "  3. Run scripts: pwsh -File script.ps1"
                echo "  4. Explore cmdlets: Get-Command -Module Microsoft.PowerShell.*"
                echo ""
              }
            '';
          };
        }
      );
    };
}
