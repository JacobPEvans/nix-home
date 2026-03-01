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

## Dev shells

The `shells/` directory contains 13+ standalone development environment templates,
each a self-contained Nix flake you can copy into any project and activate with direnv.

| Shell | Description | Key packages |
|-------|-------------|-------------|
| `ansible/` | Ansible automation | Ansible, Python, ansible-lint |
| `claude-sdk-python/` | Claude Agent SDK (Python) | Python 3.11, Anthropic SDK, pytest, ruff |
| `claude-sdk-typescript/` | Claude Agent SDK (TypeScript) | Node.js, TypeScript, ts-node |
| `containers/` | Container tooling | docker, crane, skopeo |
| `go/` | Go development | Go, gopls, delve |
| `image-building/` | Image build tooling | Packer and image build tools |
| `infrastructure-automation/` | Complete IaC toolkit | Ansible, Terraform, AWS, Packer |
| `js/` | Node.js development | Node.js, npm, yarn, pnpm |
| `kubernetes/` | Kubernetes validation and orchestration | kubectl, helm, kubeconform, kube-linter, kind, k9s |
| `powershell/` | PowerShell scripting | PowerShell 7.x, .NET SDK |
| `python/` | Basic Python development | Python, pip, venv |
| `python-data/` | Data science / ML | Python, pandas, numpy, jupyter |
| `python310/` | Python 3.10 pinned environment | Python 3.10 |
| `python312/` | Python 3.12 pinned environment | Python 3.12 |
| `python314/` | Python 3.14 pinned environment | Python 3.14 |
| `splunk-dev/` | Splunk development | Splunk SDK and tooling |
| `terraform/` | Infrastructure as Code | Terraform, Terragrunt, OpenTofu, tflint, checkov |

See [`shells/README.md`](shells/README.md) for full details and usage instructions.

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
