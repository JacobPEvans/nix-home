# Claude Agent SDK - TypeScript Development Shell
#
# Nix development environment for working with the Claude Agent SDK for TypeScript.
#
# Source: https://github.com/anthropics/claude-agent-sdk-typescript
#
# Features:
# - Node.js 20 LTS with npm, yarn, and pnpm
# - TypeScript compiler and language server
# - Development tools (prettier, eslint)
# - Pre-configured for agent development
#
# Usage:
#   cd /path/to/your/claude-agent-project
#   nix develop ~/.config/nix/shells/claude-sdk-typescript
#
# Or with direnv (create .envrc):
#   use flake ~/.config/nix/shells/claude-sdk-typescript

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "claude-sdk-typescript";

  buildInputs = with pkgs; [
    # Node.js runtime and package managers
    nodejs # Node.js LTS (nixpkgs default)
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm

    # TypeScript tooling
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.ts-node # Execute TypeScript directly

    # Development tools
    nodePackages.prettier # Code formatter
    nodePackages.eslint # Linter

    # Useful utilities
    jq # JSON processing

    # Version control
    git
  ];

  shellHook = ''
    echo "🤖 Claude Agent SDK - TypeScript Development Environment"
    echo ""
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
    echo "TypeScript version: $(tsc --version)"
    echo ""
    echo "Available tools:"
    echo "  - node/npm/yarn/pnpm: Package management"
    echo "  - typescript: TypeScript compiler"
    echo "  - ts-node: Execute TypeScript directly"
    echo "  - prettier: Code formatter"
    echo "  - eslint: Linter"
    echo ""
    echo "Quick start:"
    echo "  1. Initialize project: npm init -y"
    echo "  2. Install SDK: npm install @anthropic-ai/sdk"
    echo "  3. Set API key: export ANTHROPIC_API_KEY=<your-key>"
    echo "  4. Run examples from: https://github.com/anthropics/claude-agent-sdk-typescript"
    echo ""
    echo "Documentation:"
    echo "  - SDK: https://github.com/anthropics/claude-agent-sdk-typescript"
    echo "  - API Docs: https://docs.anthropic.com/"
    echo "  - Examples: https://github.com/anthropics/claude-agent-sdk-demos"
    echo ""

    # Set npm prefix to local directory
    export npm_config_prefix="$PWD/.npm-packages"
    export PATH="$PWD/node_modules/.bin:$npm_config_prefix/bin:$PATH"

    # Create package.json if it doesn't exist
    if [ ! -f "package.json" ]; then
      echo "💡 Tip: Run 'npm init -y' to create a package.json"
    fi
  '';

  # Environment variables
  ANTHROPIC_SDK_ENV = "development";
  NODE_ENV = "development";
}
