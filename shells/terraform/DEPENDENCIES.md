# terraform-proxmox Dependencies Mapping

Complete reference mapping all requirements from the terraform-proxmox project to Nix packages.

## Discovery Summary

The terraform-proxmox repository requires **25+ tools** across 5 functional areas:

1. Infrastructure as Code (Terraform/Terragrunt)
2. Configuration Management (Ansible)
3. Testing & Validation
4. Cloud Integration (AWS)
5. Utilities & Processors

All tools are sourced from `nixpkgs-unstable` in the development shell.

---

## Complete Dependency Mapping

### Infrastructure as Code Tools

| Requirement | Version | Nix Package | Category | Status |
|---|---|---|---|---|
| **Terraform** | ≥1.12.2 | `terraform` | Core IaC | ✓ Included |
| **Terragrunt** | ≥0.81.10 | `terragrunt` | IaC Wrapper | ✓ Included |
| OpenTofu | Latest | `opentofu` | IaC Alternative | ✓ Included |

### Terraform Providers (Auto-managed)

| Provider | Version | Management | Status |
|---|---|---|---|
| bpg/proxmox | ~0.79 | Terraform lock file | ✓ Auto |
| hashicorp/tls | ~4.1 | Terraform lock file | ✓ Auto |
| hashicorp/random | ~3.7 | Terraform lock file | ✓ Auto |
| hashicorp/local | ~2.5 | Terraform lock file | ✓ Auto |
| hashicorp/null | ~3.2 | Terraform lock file | ✓ Auto |

### Terraform Documentation & Linting

| Tool | Purpose | Nix Package | Status |
|---|---|---|---|
| **terraform-docs** | Generate module documentation | `terraform-docs` | ✓ Included |
| **TFLint** | Terraform linting | `tflint` | ✓ Included |
| TFLint (aws ruleset) | AWS-specific rules | `tflint-plugins.tflint-ruleset-aws` | Optional* |
| TFLint (google ruleset) | GCP-specific rules | `tflint-plugins.tflint-ruleset-google` | Optional* |

*\*Uncomment in flake.nix if using AWS/GCP providers extensively*

### Security & Compliance Scanning

| Tool | Purpose | Nix Package | Status |
|---|---|---|---|
| **Checkov** | Security/compliance scanning | `checkov` | ✓ Included |
| **Terrascan** | Infrastructure security | `terrascan` | ✓ Included |
| **tfsec** | Terraform security | `tfsec` | ✓ Included |
| **Trivy** | Vulnerability scanning | `trivy` | ✓ Included |
| **Infracost** | Cloud cost estimation | `infracost` | ✓ Included |

**Note:** Pre-commit config disables Checkov/Terrascan due to Rust compiler requirements. These are available in flake if needed.

### Configuration Management (Ansible)

| Tool | Purpose | Nix Package | Type | Status |
|---|---|---|---|---|
| **Ansible** | Configuration management | `ansible` | Executable | ✓ Included |
| **ansible-lint** | Playbook quality validation | `ansible-lint` | Executable | ✓ Included |
| **Molecule** | Ansible role testing | `molecule` | Executable | ✓ Included |
| **Python 3** | Ansible/Molecule runtime | `python3` | Runtime | ✓ Included |

### Ansible Collections (via ansible-galaxy)

Collections are **NOT** managed by Nix but installed with:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

| Collection | Min Version | Installation | Status |
|---|---|---|---|
| `ansible.posix` | ≥1.5.0 | Via requirements.yml | ✓ Required |
| `community.general` | ≥8.0.0 | Via requirements.yml | ✓ Required |
| `community.docker` | Latest | Optional (via pip in CI) | Optional |

### Python Packages (Handled by Nix)

These Python dependencies are included via Nix packages:

| Package | Purpose | Nix Path | Status |
|---|---|---|---|
| **ansible** | Core automation | nixpkgs#ansible | ✓ Included |
| **ansible-core** | Automation engine | (included with ansible) | ✓ Included |
| **molecule** | Testing framework | nixpkgs#molecule | ✓ Included |
| **docker** | Python Docker client | (part of molecule-plugins) | ✓ Included |
| **jinja2** | Template engine | (included with ansible) | ✓ Included |
| **pyyaml** | YAML processing | (included with ansible) | ✓ Included |

**Note:** Nix provides these as managed packages, not via pip. This ensures reproducibility.

### Cloud & Container Tools

| Tool | Purpose | Nix Package | Status |
|---|---|---|---|
| **AWS CLI v2** | Cloud credential/state management | `awscli2` | ✓ Included |
| **Docker** | Container runtime | `docker` | ✓ Included |

### Git & Pre-commit Framework

| Tool | Purpose | Nix Package | Status |
|---|---|---|---|
| **git** | Version control | `git` | ✓ Included |
| **pre-commit** | Git hooks framework | System package* | ✓ Available |

*\*pre-commit is also available in home-manager system packages*

### Data Processors & Formatters

| Tool | Purpose | Nix Package | Status |
|---|---|---|---|
| **jq** | JSON processor | `jq` | ✓ Included |
| **yq** | YAML processor | `yq` | ✓ Included |

### GitHub Actions (CI/CD)

These are **NOT** installed locally but run in GitHub:

| Workflow | Runner | Tools | Status |
|---|---|---|---|
| terraform.yml | ubuntu-latest | Terraform, terraform-docs, tflint | CI Only |
| ansible.yml | ubuntu-latest | Ansible, ansible-lint, Molecule, Docker | CI Only |
| claude-code.yml | ubuntu-latest | Claude Code integration | CI Only |
| markdown-lint.yml | ubuntu-latest | markdownlint-cli2 (v20) | CI Only |

---

## Installation Verification

Run this to verify all tools are accessible:

```bash
# Activate development environment
nix develop <path-to-your-nix-config-repo>/shells/terraform

# Verify each tool
echo "=== TERRAFORM TOOLS ==="
terraform version
terragrunt --version
terraform-docs --version
tflint --version

echo -e "\n=== SECURITY SCANNERS ==="
checkov --version
terrascan version
tfsec --version
trivy version

echo -e "\n=== ANSIBLE TOOLS ==="
ansible --version
ansible-lint --version
molecule --version
python3 --version

echo -e "\n=== CLOUD TOOLS ==="
aws --version
docker --version

echo -e "\n=== UTILITIES ==="
jq --version
yq --version
git --version
```

---

## Per-Tool Configuration

### Terraform

```hcl
# terraform version constraint
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.79"
    }
  }
}
```

### Terragrunt

```hcl
# terragrunt.hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-proxmox-state-useast2-{account-id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-proxmox-locks-useast2"
  }
}
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
- repo: https://github.com/pre-commit-terraform/pre-commit-terraform
  rev: v1.92.0
  hooks:
    - id: terraform_fmt
    - id: terraform_validate
    - id: terraform_docs
    - id: terraform_tflint
```

### Ansible Requirements

```yaml
# ansible/requirements.yml
collections:
  - name: ansible.posix
    version: ">=1.5.0"
  - name: community.general
    version: ">=8.0.0"
```

---

## Optional Enhancements

### TFLint Plugins (if needed)

Uncomment in `shells/terraform/flake.nix`:

```nix
tflint-plugins.tflint-ruleset-aws
tflint-plugins.tflint-ruleset-google
```

### Checkov/Terrascan

If you want these despite pre-commit disabling them:

```nix
# Already in flake, just uncomment
checkov
terrascan
```

### Node.js-based Tools

For prettier/markdownlint via Node (instead of CLI):

```nix
# Would add to separate Node shell or home-manager
nodejs
pnpm
```

---

## References

- [Nix Package Search](https://search.nixos.org/packages)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
