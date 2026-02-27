# Python Data Science Shell
#
# Python environment for data analysis and machine learning.
# Includes pandas, numpy, jupyter, and visualization libraries.
#
# Usage:
#   1. Copy this file to your project
#   2. Create .envrc with "use flake"
#   3. Run: direnv allow
#
# Or manually: nix develop
#
# Start Jupyter: jupyter lab

{
  description = "Python data science environment";

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
              (python312.withPackages (
                ps: with ps; [
                  # Core data science
                  pandas
                  numpy
                  scipy

                  # Visualization
                  matplotlib
                  seaborn
                  plotly

                  # Jupyter
                  jupyterlab
                  ipython
                  notebook

                  # Utilities
                  pip
                  virtualenv

                  # Add ML packages as needed:
                  # scikit-learn
                  # tensorflow
                  # torch
                ]
              ))
            ];

            shellHook = ''
              echo "Python Data Science environment ready"
              echo "  - pandas, numpy, scipy"
              echo "  - matplotlib, seaborn, plotly"
              echo "  - jupyter lab"
              echo ""
              echo "Start Jupyter: jupyter lab"
            '';
          };
        }
      );
    };
}
