# Terraform/Terragrunt Development Shell - Tool Reference

Complete infrastructure-as-code environment with all tools found in
terraform-proxmox repo plus popular community tools.

**NOTE**: This shell allows unfree packages (Terraform uses BSL license).
OpenTofu is included as a fully open-source alternative.

## Terraform/Terragrunt Tools

- **terraform**: Core IaC tool
- **terragrunt**: Terraform wrapper for DRY configurations
- **opentofu**: Open source Terraform fork
- **terraform-docs**: Auto-generate documentation from modules
- **tflint**: Terraform linter for best practices

## Security Scanners

- **checkov**: Security/compliance scanner (Bridgecrew)
- **terrascan**: Security scanner (Tenable)
- **tfsec**: Security scanner (Aqua)
- **trivy**: Comprehensive vulnerability scanner
- **infracost**: Cloud cost estimation

## Configuration Management & Testing (Ansible/Molecule)

- **ansible**: Configuration management and automation
- **ansible-lint**: Ansible playbook linting
- **molecule**: Ansible role testing framework
- **python3**: Runtime for Ansible, Molecule, and pip packages

## Cloud & State Management

- **aws-cli**: AWS CLI for S3 backend and credential management
- **docker**: Container runtime for Molecule testing

## Proxmox Management

- **proxmox-backup-client**: Backup client utilities
- **Python proxmoxer**: Available via pip for API access
- **pvesh/qm/pct**: Host-only tools (access via SSH to Proxmox host)

## Git & Utilities

- **pre-commit**: Git hooks framework (also in system packages)
- **markdownlint-cli2**: Markdown linting (also in system packages)
- **jq**: JSON processor
- **yq**: YAML processor
- **git**: Version control

## Usage

1. From project root: `nix develop`
2. Or create `.envrc` with `use flake` and run `direnv allow`

## Python Packages (from nixpkgs)

- **ansible**: Core automation tool
- **molecule**: Testing framework
- **docker**: Python Docker client (for Molecule)
