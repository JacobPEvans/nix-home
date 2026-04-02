# AWS CLI Configuration
#
# Manages ~/.aws/config via shell init (not home.activation).
# Profile structure defined here in Nix (single source of truth).
# Account ID injected from macOS Keychain at shell startup via ensure-config.zsh.
# Credentials: use aws-vault (backed by macOS Keychain), never ~/.aws/credentials.

{
  pkgs,
  userConfig ? { },
  ...
}:

let
  defaultRegion = "us-east-2";
  defaultOutput = "json";

  # Placeholder replaced at shell init by keychain lookup
  accountIdPlaceholder = "__AWS_ACCOUNT_ID__";

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
    {
      name = "tf-runs-on";
      comment = "tf-runs-on: EC2, App Runner, SQS, DynamoDB, S3, IAM, CloudWatch, Budgets, SNS";
      source_profile = "terraform";
      role_arn = "arn:aws:iam::${accountIdPlaceholder}:role/tf-runs-on";
    }
  ];

  generateProfile =
    profile:
    let
      # AWS CLI format: default profile has no "profile " prefix
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

  configContent = builtins.concatStringsSep "\n\n" (map generateProfile profiles);
  configContentFile = pkgs.writeText "aws-config-template" configContent;
  kcAccount = (userConfig.keychain or { }).aiAccount or "";
  kcDb = (userConfig.keychain or { }).aiDb or "";

  ensureScript = pkgs.replaceVars ./ensure-config.zsh {
    templatePath = configContentFile;
    inherit kcAccount kcDb;
    placeholder = accountIdPlaceholder;
    sed = "${pkgs.gnused}/bin/sed";
  };
in
{
  initScript = ensureScript;
}
