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

## Prerequisites

- [Nix](https://nixos.org/) (Determinate Nix installer recommended)
- [home-manager](https://github.com/nix-community/home-manager)
- Compatible platforms: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`

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
| `checks` | Formatting, linting, dead code, module eval (4 systems) |
| `devShells.default` | Nix development tools |
| `formatter` | nixfmt-tree |
| `templates` | Per-repo devShell scaffolding (5 templates) |

## Templates

Each project owns its own devShell. Use the `templates` flake output to scaffold a
`flake.nix` + `.envrc` into any repo — then activate with direnv.

| Template | Description |
|----------|-------------|
| `ansible` | Ansible configuration management dev environment |
| `terraform` | Terraform/Terragrunt infrastructure dev environment |
| `kubernetes` | Kubernetes development and validation environment |
| `containers` | Container development, building, and registry environment |
| `splunk-dev` | Splunk development environment (Python 3.9 via uv) |

```sh
# Scaffold a new repo's dev environment
nix flake init -t github:JacobPEvans/nix-home#ansible
nix flake init -t github:JacobPEvans/nix-home#terraform
nix flake init -t github:JacobPEvans/nix-home#kubernetes
nix flake init -t github:JacobPEvans/nix-home#containers
nix flake init -t github:JacobPEvans/nix-home#splunk-dev

# Then allow direnv (one-time per worktree)
direnv allow
```

For standard languages, use community templates:

```sh
nix flake init -t github:the-nix-way/dev-templates#go
nix flake init -t github:the-nix-way/dev-templates#node
```

### Monitoring

The `modules/monitoring/` module deploys a Kubernetes-based observability stack for
AI development workflows. It includes OpenTelemetry Collector for traces and log ingestion,
and Cribl Edge for log shipping. See [`modules/monitoring/README.md`](modules/monitoring/README.md)
for architecture details, components, and quick start instructions.

## Part of a trio

| Repo | What it does |
|------|-------------|
| [nix-ai](https://github.com/JacobPEvans/nix-ai) | AI coding tools (Claude, Gemini, Copilot) |
| **nix-home** (you are here) | Dev environment |
| [nix-darwin](https://github.com/JacobPEvans/nix-darwin) | macOS system config (consumes both) |

## License

MIT
