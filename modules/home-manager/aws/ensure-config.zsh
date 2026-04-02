# AWS config generator — ensures ~/.aws/config has real values
# Substitutes account ID from macOS Keychain into the Nix-managed template
# Sourced from zsh initContent — runs as the user with full keychain access
#
# @-prefixed tokens are replaced by pkgs.replaceVars at Nix build time

_aws_config_ensure() {
  [[ "$OSTYPE" != darwin* ]] && return 0

  local config_file="$HOME/.aws/config"

  # Fast path: skip if file was generated from this template version
  [[ -f "$config_file" ]] && grep -qF "@templatePath@" "$config_file" && return 0

  [[ -z "@kcAccount@" || -z "@kcDb@" ]] && return 0

  local acct_id
  if ! acct_id=$(security find-generic-password \
    -s "AWS_ACCOUNT_ID" \
    -a "@kcAccount@" \
    -w "@kcDb@" 2>/dev/null); then
    echo "aws-config: keychain lookup failed for AWS_ACCOUNT_ID" >&2
    return 0
  fi

  if [[ -z "$acct_id" ]]; then
    echo "aws-config: AWS_ACCOUNT_ID not found in keychain for account @kcAccount@" >&2
    return 0
  fi

  mkdir -p "$HOME/.aws"
  {
    echo "# Generated from @templatePath@"
    @sed@ "s/@placeholder@/$acct_id/g" "@templatePath@"
  } > "$config_file"
}
_aws_config_ensure
