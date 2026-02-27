# Terraform/Terragrunt & Ansible Development Shell

Complete Nix-based development environment for the terraform-proxmox project, with all required tools at their latest nixpkgs versions.

## Quick Start

```bash
# From terraform-proxmox project root
nix develop <path-to-your-nix-config-repo>/shells/terraform

# Or with direnv (one-time setup)
echo "use flake <path-to-your-nix-config-repo>/shells/terraform" > .envrc
direnv allow
```

## What's Included

### Infrastructure as Code (Terraform/Terragrunt)

- **terraform** - Main IaC provisioning tool (≥1.12.2)
- **terragrunt** - DRY configuration wrapper (≥0.81.10)
- **opentofu** - Open-source Terraform alternative

### Documentation & Linting

- **terraform-docs** - Auto-generate module documentation
- **tflint** - Terraform best practices linter

### Security Scanning

- **checkov** - Security/compliance scanning
- **terrascan** - Infrastructure security validation
- **tfsec** - Terraform-specific security scanning
- **trivy** - Comprehensive vulnerability scanner

### Configuration Management (Ansible)

- **ansible** - Agentless automation & configuration management
- **ansible-lint** - Playbook quality validation
- **molecule** - Ansible role testing framework
- **python3** - Runtime for Ansible, Molecule, and pip packages

### Cloud & Container Tools

- **awscli2** - AWS CLI for S3 state backend & credential management
- **docker** - Container runtime for Molecule testing

### Utilities

- **git** - Version control
- **jq** - JSON processor
- **yq** - YAML processor

---

## Terraform Providers

The following providers are automatically managed by Terraform:

- **bpg/proxmox** (~0.79)
- **hashicorp/tls** (~4.1)
- **hashicorp/random** (~3.7)
- **hashicorp/local** (~2.5)
- **hashicorp/null** (~3.2)

These are handled by `terragrunt init` - no Nix configuration needed.

---

## Ansible Collections

Install required Ansible collections from `ansible/requirements.yml`:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

Collections needed:

- `ansible.posix` (≥1.5.0)
- `community.general` (≥8.0.0)
- `community.docker` (optional, for Docker integration)

---

## Pre-commit Hooks

The terraform-proxmox project uses pre-commit for code quality:

```bash
# Install hooks (run once)
pre-commit install

# Run checks manually
pre-commit run --all-files
```

Hooks configured:

- `terraform_fmt` - Format Terraform code
- `terraform_validate` - Validate Terraform syntax
- `terraform_docs` - Generate module documentation
- `terraform_tflint` - Lint with tflint
- Standard hooks (trailing whitespace, YAML validation, etc.)

---

## AWS & Proxmox Configuration

### AWS Credentials (for Terraform state backend)

```bash
aws configure
# Enter AWS Access Key, Secret Key, region, output format
```

### Proxmox API Token

Set as environment variable:

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pam!terraform"
export PM_API_TOKEN_SECRET="<your-token-secret>"
```

Or configure in `terraform.tfvars`:

```hcl
proxmox_api_url = "https://proxmox.example.com:8006/api2/json"
```

---

## Testing the Environment

```bash
# Activate development shell
nix develop <path-to-your-nix-config-repo>/shells/terraform

# Verify all tools
terraform version
terragrunt --version
ansible --version
docker --version
aws --version
molecule --version

# Initialize Terraform
cd ~/git/terraform-proxmox
terragrunt init

# Run pre-commit checks
pre-commit run --all-files

# Test Ansible setup
ansible-inventory --list
ansible-lint -v

# Test Molecule (requires Docker)
molecule test
```

---

## File Organization

```text
shells/terraform/
├── flake.nix              # Nix development environment definition
├── README.md              # This file
└── DEPENDENCIES.md        # Complete dependency mapping

terraform-proxmox/
├── terragrunt.hcl         # Terragrunt configuration
├── main.tf                # Terraform providers & backend
├── modules/               # Terraform modules
├── ansible/               # Ansible playbooks & roles
│   └── requirements.yml   # Ansible collection dependencies
├── .pre-commit-config.yaml # Git hooks configuration
└── .github/workflows/      # CI/CD pipeline definitions
```

---

## Troubleshooting

### "ansible: command not found"

→ Run `nix develop <path-to-your-nix-config-repo>/shells/terraform` first

### "docker: Cannot connect to Docker daemon"

→ Docker daemon needs to be running: `colima start` or launch Docker.app

### "terraform: Error reading credentials from file"

→ Run `aws configure` to set up AWS credentials

### "Molecule tests fail with image not found"

→ Pull test image: `docker pull geerlingguy/docker-ubuntu2404-ansible:latest`

### Ansible collections not found

→ Install requirements: `ansible-galaxy collection install -r ansible/requirements.yml`

---

## Further Reading

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Nix Flakes Guide](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html)
