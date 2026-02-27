# nix-home

## Your dev environment, declared once. Works everywhere

Dotfiles, but better. Instead of fragile symlinks and install scripts,
**nix-home** declares your development environment as code using [Nix](https://nixos.org/).
Switch machines? One command. Everything's back.

---

## What it manages

| Tool | What you get |
|------|-------------|
| **Git** | Aliases, GPG signing, hooks, merge drivers |
| **Zsh** | Oh-my-zsh, aliases, autosuggestions, syntax highlighting, custom functions |
| **VS Code** | Writable settings merge, extensions, keybindings |
| **Tmux** | Session management configuration |
| **Direnv** | Automatic per-project environments |
| **Monitoring** | Kubernetes manifests, OpenTelemetry, Cribl Edge |
| **Linters** | markdownlint, pre-commit configurations |
| **npm / AWS** | Configuration file management |

## Quick start

Add to your Nix flake:

```nix
{
  inputs.nix-home = {
    url = "github:JacobPEvans/nix-home";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
}
```

Then in your home-manager config:

```nix
sharedModules = [ nix-home.homeManagerModules.default ];
```

## Flake outputs

| Output | Description |
|--------|-------------|
| `homeManagerModules.default` | Full cross-platform module |
| `overlays.default` | Python package overrides |
| `checks` | Formatting, linting, dead code (4 systems) |
| `devShells.default` | Nix development tools |
| `formatter` | nixfmt-tree |

## Part of a trio

| Repo | What it does |
|------|-------------|
| [nix-ai](https://github.com/JacobPEvans/nix-ai) | AI coding tools (Claude, Gemini, Copilot) |
| **nix-home** (you are here) | Dev environment |
| [nix-config](https://github.com/JacobPEvans/nix-config) | macOS system config (consumes both) |

## License

MIT
