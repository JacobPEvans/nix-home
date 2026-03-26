# AWS CLI Configuration
#
# Manages ~/.aws/config via home-manager.
# On Darwin, an activation script writes the file directly so that
# the __AWS_ACCOUNT_ID__ placeholder can be substituted from macOS Keychain.
# home.file creates immutable nix store symlinks that sed cannot modify in-place.
#
# Credentials: use aws-vault (backed by macOS Keychain), never ~/.aws/credentials.

{
  config,
  lib,
  pkgs,
  userConfig ? { },
  ...
}:

let
  defaultRegion = "us-east-2";
  defaultOutput = "json";

  # Placeholder replaced at activation time by keychain lookup
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
  configPath = "${config.home.homeDirectory}/.aws/config";
  kcAccount = (userConfig.keychain or { }).aiAccount or "";
  kcDb = (userConfig.keychain or { }).aiDb or "";
in
lib.optionalAttrs pkgs.stdenv.isDarwin {
  activation.awsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${config.home.homeDirectory}/.aws"
    rm -f "${configPath}"

    _AWS_ACCT_ID=$(security find-generic-password -s "AWS_ACCOUNT_ID" -a "${kcAccount}" -w "${kcDb}" 2>/dev/null || true)
    if [ -z "$_AWS_ACCT_ID" ]; then
      echo "WARNING: AWS_ACCOUNT_ID not found in keychain. ~/.aws/config role ARNs will contain placeholders."
      echo "  Fix: security add-generic-password -U -s AWS_ACCOUNT_ID -a ${kcAccount} -w YOUR_ACCOUNT_ID ~/Library/Keychains/${kcDb}"
    fi

    if [ -n "$_AWS_ACCT_ID" ]; then
      ${pkgs.gnused}/bin/sed "s/${accountIdPlaceholder}/$_AWS_ACCT_ID/g" "${configContentFile}" > "${configPath}"
    else
      cat "${configContentFile}" > "${configPath}"
    fi
  '';
}
// lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
  ".aws/config".text = configContent;
}
