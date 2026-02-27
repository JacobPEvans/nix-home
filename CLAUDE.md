# nix-home - AI Agent Instructions

Cross-platform home-manager modules for development environment tools.

## Critical Constraints

1. **Flakes-only**: Never use `nix-env` or imperative Nix commands
2. **Cross-platform**: Modules must work on Darwin and Linux (4 systems)
3. **Worktrees required**: Run `/init-worktree` before any work
4. **No direct main commits**: Always use feature branches

## Build Validation

```bash
nix flake check    # Runs formatting, statix, deadnix, shellcheck checks
nix fmt            # Fix formatting
```

## Architecture

This repo exports home-manager modules consumed by nix-config (nix-darwin):

- `homeManagerModules.default` -- Full cross-platform module (git, zsh, VS Code, tmux, monitoring)
- `overlays.default` -- Python package overrides
- `checks` -- Quality checks on 4 systems
- `devShells.default` -- Nix development tools

## Key Files

- `modules/home-manager/common.nix` -- Shared configuration (zsh, git, direnv, npm, AWS, linters)
- `modules/home-manager/tmux.nix` -- Tmux configuration
- `modules/monitoring/` -- Kubernetes monitoring stack
- `overlays/python-packages.nix` -- Custom Python package overlays
- `shells/` -- Development shell environments (Python, Go, Terraform, K8s, etc.)
- `lib/checks.nix` -- Quality check definitions

## Testing Locally

From nix-config (nix-darwin), test changes with:

```bash
sudo darwin-rebuild switch --flake . --override-input nix-home /Users/you/git/nix-home/main
```

## Part of a Trio

| Repo | Purpose |
|------|---------|
| [nix-ai](https://github.com/JacobPEvans/nix-ai) | AI coding tools (Claude, Gemini, Copilot) |
| **nix-home** (this repo) | Dev environment |
| [nix-darwin](https://github.com/JacobPEvans/nix-darwin) | macOS system config (consumes both) |
