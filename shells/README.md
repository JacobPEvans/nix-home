# Development Shell Templates

Per-project development environments using Nix flakes with direnv integration.

## Quick Start

1. Copy desired flake to your project:

   ```bash
   cp ~/.config/nix/shells/python/flake.nix ~/myproject/
   ```

2. Create `.envrc` in your project:

   ```bash
   echo "use flake" > ~/myproject/.envrc
   ```

3. Allow direnv:

   ```bash
   cd ~/myproject && direnv allow
   ```

The environment will now load automatically when you `cd` into the project.

## Available Templates

| Template | Description | Key Packages |
| -------- | ----------- | ------------ |
| `python/` | Basic Python development | Python, pip, venv |
| `python-data/` | Data science / ML | Python, pandas, numpy, jupyter |
| `js/` | Node.js development | Node.js, npm, yarn, pnpm |
| `go/` | Go development | Go, gopls, delve |
| `powershell/` | PowerShell scripting | PowerShell 7.x, .NET SDK, jq, yq |
| `ansible/` | Ansible automation | Ansible, Python, ansible-lint |
| `containers/` | Docker, BuildKit, registry tools | docker, crane, skopeo |
| `kubernetes/` | Kubernetes validation and orchestration | kubeconform, kube-linter, kubectl, helm, kind |
| `terraform/` | Infrastructure as Code | Terraform, Terragrunt, etc. |
| `infrastructure-automation/` | Complete IaC toolkit | Ansible, Terraform, AWS, Packer |
| `claude-sdk-python/` | Claude Agent SDK (Python) | Python 3.11, SDK, testing |
| `claude-sdk-typescript/` | Claude SDK (TypeScript) | Node.js, TypeScript |

## Customization

Each `flake.nix` can be customized for your project needs:

- Add packages to `buildInputs`
- Add Python packages to the `withPackages` list
- Set environment variables in `shellHook`

## Updating Dependencies

```bash
# Update flake.lock in your project
nix flake update
```

## Without direnv

You can also use these directly:

```bash
# Enter shell manually
nix develop ~/myproject

# Or run a single command
nix develop ~/myproject -c python --version
```

## Template Details

### Kubernetes (`kubernetes/`)

Complete Kubernetes development and validation environment:

| Category | Tools |
| -------- | ----- |
| Core CLI | kubectl, kubectx, kubens |
| Package Management | helm, helmfile, kustomize, helm-docs |
| Validation | kubeconform (schema validation), kube-linter (best practices), conftest (OPA policies), pluto (deprecated APIs) |
| Terminal UI | k9s, stern (multi-pod log tailing) |
| Local Testing | kind (Kubernetes IN Docker) |

**Workflow:**

```bash
# Validate manifests against schema
kubeconform -summary manifests/

# Lint for best practices
kube-linter lint .

# Check for deprecated API versions
pluto detect-files -d .

# Local cluster for testing
kind create cluster --name dev
kubectl apply -f manifests/
k9s
```

### Terraform/Terragrunt (`terraform/`)

Complete Infrastructure-as-Code development environment:

| Category | Tools |
| -------- | ----- |
| Core IaC | terraform, terragrunt, opentofu |
| Documentation | terraform-docs |
| Linting | tflint |
| Security Scanners | checkov, terrascan, tfsec, trivy |
| Cost Estimation | infracost |
| Utilities | jq, yq |

**Note:** Terraform uses BSL license (unfree). This shell enables `allowUnfree`.
OpenTofu is included as a fully open-source alternative.

**Note:** `pre-commit` and `markdownlint-cli2` are already available system-wide
via `modules/common/packages.nix` - no need to add them to project shells.

### PowerShell Shell (`powershell/`)

Cross-platform PowerShell 7.x development environment.

**Tools:** PowerShell 7.5+, .NET SDK 8.0+, jq, yq, curl, git

**Use cases:**

- Cross-platform automation scripts
- PowerShell module development
- API integration scripting
- File and data processing tasks

### Claude Agent SDK Shells (`claude-sdk-*/`)

Development environments for building AI agents with Claude:

**Python SDK** (`claude-sdk-python/`):

- Python 3.11+ with modern package management
- Anthropic Python SDK pre-installed
- Testing tools (pytest, pytest-asyncio)
- Code quality tools (black, mypy, ruff)
- Interactive IPython shell with rich formatting

**TypeScript SDK** (`claude-sdk-typescript/`):

- Node.js 20 LTS with npm, yarn, pnpm
- TypeScript compiler and language server
- Development tools (prettier, eslint)
- ts-node for direct TypeScript execution

Both shells include:

- Pre-configured environment for Claude API development
- Links to official SDK repositories and documentation
- Quick start examples and usage guides
- See individual README.md files in each directory for details
