# Claude Agent SDK - Python Development Shell
#
# Nix development environment for working with the Claude Agent SDK for Python.
#
# Source: https://github.com/anthropics/claude-agent-sdk-python
#
# Features:
# - Python 3.11+ with pip and virtualenv
# - Anthropic Python SDK
# - Development tools (pytest, black, mypy, ruff)
# - Pre-configured for agent development
#
# Usage:
#   cd /path/to/your/claude-agent-project
#   nix develop ~/.config/nix/shells/claude-sdk-python
#
# Or with direnv (create .envrc):
#   use flake ~/.config/nix/shells/claude-sdk-python

{
  pkgs ? import <nixpkgs> { },
}:

let
  # DRY: Define Python version once, use throughout
  python = pkgs.python311;
  pythonPackages = pkgs.python311Packages;
in
pkgs.mkShell {
  name = "claude-sdk-python";

  buildInputs = [
    # Python runtime and package management
    python
    pythonPackages.pip
    pythonPackages.virtualenv
    pythonPackages.setuptools

    # Anthropic SDK dependencies
    pythonPackages.anthropic # Claude API SDK
    pythonPackages.httpx # HTTP client
    pythonPackages.pydantic # Data validation

    # Development tools
    pythonPackages.pytest # Testing framework
    pythonPackages.pytest-asyncio # Async test support
    pythonPackages.black # Code formatter
    pythonPackages.mypy # Type checker
    pythonPackages.ruff # Fast linter

    # Useful utilities
    pythonPackages.ipython # Interactive shell
    pythonPackages.rich # Pretty printing

    # Version control
    pkgs.git
  ];

  shellHook = ''
    echo "🤖 Claude Agent SDK - Python Development Environment"
    echo ""
    echo "Python version: $(python --version)"
    echo "Available tools:"
    echo "  - anthropic: Claude API Python SDK (pre-installed)"
    echo "  - pytest: Testing framework"
    echo "  - black: Code formatter"
    echo "  - mypy: Type checker"
    echo "  - ruff: Fast linter"
    echo ""
    echo "Quick start:"
    echo "  1. Set API key: export ANTHROPIC_API_KEY=<your-key>"
    echo "  2. Run examples from: https://github.com/anthropics/claude-agent-sdk-python"
    echo ""
    echo "Documentation:"
    echo "  - SDK: https://github.com/anthropics/claude-agent-sdk-python"
    echo "  - API Docs: https://docs.anthropic.com/"
    echo "  - Examples: https://github.com/anthropics/claude-agent-sdk-demos"
    echo ""

    # Create local virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating Python virtual environment..."
      python -m venv .venv
      echo "Run 'source .venv/bin/activate' to activate the virtual environment"
    fi
  '';

  # Environment variables
  ANTHROPIC_SDK_ENV = "development";
}
