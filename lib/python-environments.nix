# Python Development Environments
#
# Shared, modular definitions for Python versions and package configurations.
# All packages are installed via Nix - pip is intentionally excluded.
#
# Available via Nix (nixpkgs-25.11): 3.10, 3.11, 3.12, 3.13, 3.14
# For EOL versions (3.9): Use `uv run --python 3.9` (on-demand download)
#
# Usage:
#   pythonEnvs = import ./lib/python-environments.nix { inherit pkgs; };
#   pythonEnvs.versions.py312                    # Python 3.12 interpreter
#   pythonEnvs.packageSets.dev                   # Dev tools package function
#   pythonEnvs.mkDevShell { ... }                # Create a dev shell
#
# Design goals:
# - Nix-only: No pip, virtualenv, or imperative package management
# - DRY: Versions, packages, and shell generator defined once
# - Composable: Mix versions and package sets as needed

{ pkgs }:

rec {
  # ===========================================================================
  # Python Versions
  # ===========================================================================
  # All available Python interpreters from nixpkgs-25.11
  # NOTE: Python 3.9 is EOL. Use `uv run --python 3.9` for Splunk testing.
  versions = {
    py310 = pkgs.python310; # 3.10.x - Older compatibility
    py311 = pkgs.python311; # 3.11.x - Claude SDK
    py312 = pkgs.python312; # 3.12.x - General development
    py313 = pkgs.python3; # 3.13.x - System default
    py314 = pkgs.python314; # 3.14.x - Bleeding edge
  };

  # ===========================================================================
  # Package Sets (Nix-only, no pip)
  # ===========================================================================
  # Functions that take a Python package set and return a list of packages.
  # All packages come from nixpkgs - no pip or runtime package management.
  packageSets = {
    # Minimal: Just the interpreter (no dev tools)
    # Use for: Quick scripts, compatibility testing
    minimal = _: [ ];

    # Development: Testing, linting, formatting, type checking
    # Use for: General Python development, CI/CD
    dev =
      ps: with ps; [
        # Testing
        pytest # Test framework
        pytest-asyncio # Async test support
        pytest-cov # Coverage plugin
        coverage # Coverage measurement

        # Code quality
        ruff # Fast linter and formatter
        mypy # Static type checker
        black # Code formatter

        # Interactive
        ipython # Enhanced REPL
      ];

    # Data science: Analysis and visualization
    # Use for: Data projects, notebooks
    data =
      ps: with ps; [
        pandas # Data manipulation
        numpy # Numerical computing
        scipy # Scientific computing
        jupyter # Interactive notebooks
        matplotlib # Plotting
      ];

    # Ansible/Configuration Management: SSH, JSON diffing, YAML
    # Use for: Infrastructure automation, Ansible development, config validation
    ansible =
      ps: with ps; [
        paramiko # SSH library for Ansible connections
        jsondiff # JSON comparison for config validation
        pyyaml # YAML processing
        jinja2 # Template engine
      ];
  };

  # ===========================================================================
  # Shell Generator (DRY)
  # ===========================================================================
  # Creates a development shell with specified Python version and packages.
  #
  # Arguments:
  #   python: Python interpreter (e.g., versions.py312)
  #   packages: Package set function (e.g., packageSets.dev)
  #   name: Shell name (e.g., "python312-dev")
  #   extraBuildInputs: Additional packages (default: [])
  #   shellHookExtra: Additional shell hook commands (default: "")
  #
  # Returns: A mkShell derivation
  mkDevShell =
    {
      python,
      packages ? packageSets.minimal,
      name ? "python-dev",
      extraBuildInputs ? [ ],
      shellHookExtra ? "",
    }:
    pkgs.mkShell {
      inherit name;

      buildInputs = [ (python.withPackages packages) ] ++ extraBuildInputs;

      shellHook = ''
        echo "======================================"
        echo "Python Development Environment"
        echo "======================================"
        echo ""
        echo "$(python --version)"
        echo ""
        echo "Packages installed via Nix (no pip)."
        echo "Add packages to your shell's flake.nix or project's flake.nix."
        echo ""
        ${shellHookExtra}
      '';
    };

  # ===========================================================================
  # Pre-configured Shells (convenience)
  # ===========================================================================
  # Ready-to-use shell configurations for common use cases.
  shells = {
    py310-minimal = mkDevShell {
      python = versions.py310;
      packages = packageSets.minimal;
      name = "python310-minimal";
    };
    py312-dev = mkDevShell {
      python = versions.py312;
      packages = packageSets.dev;
      name = "python312-dev";
    };
    py314-dev = mkDevShell {
      python = versions.py314;
      packages = packageSets.dev;
      name = "python314-dev";
    };
  };
}
