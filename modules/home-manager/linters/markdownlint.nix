# Markdownlint Configuration
#
# Provides global markdownlint-cli2 configuration for all markdown validation.
# This configuration is used by:
# - Pre-commit hooks during git commit
# - Claude Code markdown validation plugin
# - Manual markdown validation runs
#
# Configuration:
# - MD013: Line length set to 160 characters
# - MD013 for tables: disabled (false)
# - MD060: Disabled due to version mismatch between GitHub Actions and nixpkgs
# - fix: true (auto-fix issues where possible)
# - gitignore: true (respect .gitignore patterns)
#
# Usage:
#   markdownlint-cli2 --config ~/.markdownlint-cli2.jsonc <file>
#   pre-commit run markdownlint-cli2 --all-files

{ config, ... }:

{
  # ~/.markdownlint-cli2.jsonc - Markdownlint configuration (JSONC format)
  ".markdownlint-cli2.jsonc".source = ../../../.markdownlint-cli2.jsonc;
}
