# AWS CLI Configuration
#
# Manages AWS CLI configuration via home-manager.
# The config file sets default region and output format.
#
# Files managed:
#   ~/.aws/config - AWS CLI profiles and settings
#
# Files NOT managed (contain secrets):
#   ~/.aws/credentials - Access keys (use aws-vault instead)
#
# Security:
#   - Use aws-vault for credential management (uses macOS Keychain)
#   - Never store access keys in ~/.aws/credentials directly
#   - Use IAM Identity Center (SSO) or short-term credentials
#
# Usage:
#   aws configure list                      # Show current configuration
#   aws sts get-caller-identity             # Verify credentials
#   aws-vault exec <profile> -- aws s3 ls   # Execute with vault credentials
#
# Profile inheritance:
#   - [default] is the literal default profile (used when no --profile specified)
#   - Other profiles do NOT inherit from [default] automatically
#   - Use source_profile to chain profiles for role assumption
#
# Common config options (per profile):
#   region           - AWS region (us-east-2, etc.)
#   output           - Format: json, yaml, text, table
#   cli_pager        - Pager for output (empty string to disable)
#   cli_auto_prompt  - Auto-prompt mode: on, on-partial, off
#   retry_mode       - Retry strategy: legacy, standard, adaptive
#   max_attempts     - Max retry attempts (default: 5)
#   duration_seconds - Session duration for assumed roles (900-43200)
#
# SSO options (IAM Identity Center):
#   sso_start_url    - Portal URL
#   sso_region       - SSO endpoint region
#   sso_account_id   - AWS account ID
#   sso_role_name    - Role to assume
#
# Role assumption options:
#   role_arn         - Role ARN to assume
#   source_profile   - Profile with credentials for assuming role
#   mfa_serial       - MFA device ARN (required if role needs MFA)
#   external_id      - External ID for cross-account roles

{
  config,
  lib,
  pkgs,
  userConfig ? { },
  ...
}:

let
  # Default values for all profiles (change here to update all)
  defaultRegion = "us-east-2";
  defaultOutput = "json";

  # Placeholder replaced at activation time by keychain lookup
  accountIdPlaceholder = "__AWS_ACCOUNT_ID__";

  # A single list to define all profiles
  profiles = [
    {
      name = "default";
      comment = "Default profile - used when no --profile is specified";
    }
    {
      name = "dev";
      comment = "Development environment";
    }
    {
      name = "test";
      comment = "Test environment";
    }
    {
      name = "terraform";
      comment = "Terraform base identity - only sts:AssumeRole, no resource permissions";
    }
    {
      name = "cribl";
      comment = "Cribl environment";
    }
    {
      name = "splunk";
      comment = "Splunk environment";
    }
    {
      name = "iam-user";
      comment = "IAM admin - bootstrap only, not for daily use";
    }

    # Per-project Terraform profiles — assume role via base terraform identity
    {
      name = "tf-splunk-aws";
      comment = "tf-splunk-aws: EC2, VPC, S3, IAM, SSM, CloudWatch, EventBridge";
      source_profile = "terraform";
      role_arn = "arn:aws:iam::${accountIdPlaceholder}:role/tf-splunk-aws";
    }
    {
      name = "tf-proxmox";
      comment = "tf-proxmox: Route53 DNS records";
      source_profile = "terraform";
      role_arn = "arn:aws:iam::${accountIdPlaceholder}:role/tf-proxmox";
    }
    {
      name = "tf-bedrock";
      comment = "tf-bedrock: Bedrock, CloudFormation, Lambda, IAM, CloudWatch, Budgets";
      source_profile = "terraform";
      role_arn = "arn:aws:iam::${accountIdPlaceholder}:role/tf-bedrock";
    }
    {
      name = "tf-static-website";
      comment = "tf-static-website: S3, CloudFront, ACM, Route53";
      source_profile = "terraform";
      role_arn = "arn:aws:iam::${accountIdPlaceholder}:role/tf-static-website";
    }
  ];

  # A function to generate a single profile block from a definition
  generateProfile =
    profile:
    let
      base = ''
        # ${profile.comment}
        [${if profile.name == "default" then "default" else "profile ${profile.name}"}]
        region = ${defaultRegion}
        output = ${defaultOutput}
      '';
      role = ''
        source_profile = ${profile.source_profile}
        role_arn = ${profile.role_arn}
      '';
    in
    if profile ? role_arn && profile ? source_profile then base + role else base;
in
{
  # ~/.aws/config - AWS CLI configuration (placeholder substituted by activation hook)
  ".aws/config".text = builtins.concatStringsSep "\n\n" (map generateProfile profiles);

}
// lib.optionalAttrs pkgs.stdenv.isDarwin (
  let
    kcAccount = (userConfig.keychain or { }).aiAccount or "";
    kcDb = (userConfig.keychain or { }).aiDb or "";
  in
  {
    # Activation hook: substitute __AWS_ACCOUNT_ID__ placeholder with value from macOS Keychain
    # Runs after writeBoundary (when home.file entries have been written)
    # Darwin-only: uses macOS `security` CLI for keychain access
    # One-time setup (values from userConfig.keychain in nix-darwin's lib/user-config.nix):
    #   security unlock-keychain ~/Library/Keychains/<aiDb>
    #   security add-generic-password -U -s "AWS_ACCOUNT_ID" -a "<aiAccount>" -w "<account-id>" ~/Library/Keychains/<aiDb>
    activation.awsConfigAccountId = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      _AWS_ACCT_ID=$(security find-generic-password -s "AWS_ACCOUNT_ID" -a "${kcAccount}" -w "${kcDb}" 2>/dev/null || true)
      if [ -z "$_AWS_ACCT_ID" ]; then
        echo "WARNING: AWS_ACCOUNT_ID not found in keychain. ~/.aws/config role ARNs will be broken."
        echo "  Fix: security unlock-keychain ~/Library/Keychains/${kcDb}"
        echo "        security add-generic-password -U -s AWS_ACCOUNT_ID -a ${kcAccount} -w YOUR_ACCOUNT_ID ~/Library/Keychains/${kcDb}"
      else
        ${pkgs.gnused}/bin/sed -i "s/${accountIdPlaceholder}/$_AWS_ACCT_ID/g" ${config.home.homeDirectory}/.aws/config
      fi
    '';
  }
)
