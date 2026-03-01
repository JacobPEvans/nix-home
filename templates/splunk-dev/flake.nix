# Splunk Development Shell (Python 3.9 via uv)
#
# Python 3.9 is EOL and not available in nixpkgs, so this shell uses `uv`
# to download the interpreter on-demand from python-build-standalone.
#
# This is the ONLY Python environment that uses uv for packages.
# All other Python versions use Nix-only package management.
#
# Usage: nix develop or direnv (use flake)
#
# Commands:
#   uv run --python 3.9 python script.py     # Run script
#   uv run --python 3.9 pytest tests/        # Run tests
#   uv run --python 3.9 --with splunk-sdk python  # With package

{
  description = "Splunk development (Python 3.9 via uv - EOL exception)";

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
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "splunk-dev";

          buildInputs = with pkgs; [
            uv # Provides Python 3.9 on-demand
            git
          ];

          shellHook = ''
            echo "======================================"
            echo "Splunk Development (Python 3.9 via uv)"
            echo "======================================"
            echo ""
            echo "Python 3.9 is EOL and not in nixpkgs."
            echo "uv downloads it on-demand (~30MB, cached)."
            echo ""
            echo "Usage:"
            echo "  uv run --python 3.9 python script.py"
            echo "  uv run --python 3.9 pytest tests/"
            echo "  uv run --python 3.9 --with splunk-sdk python"
            echo ""

            # Pre-fetch Python 3.9
            if ! uv python find 3.9 >/dev/null 2>&1; then
              echo "Downloading Python 3.9..."
              uv python install 3.9
            fi
          '';
        };
      });
    };
}
