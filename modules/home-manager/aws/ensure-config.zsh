# AWS config generator — ensures ~/.aws/config has real values
# Substitutes account ID from macOS Keychain into the Nix-managed template
# Sourced from zsh initContent — runs as the user with full keychain access
#
# @-prefixed tokens are replaced by pkgs.replaceVars at Nix build time

_aws_config_ensure() {
  [[ "$(uname)" != "Darwin" ]] && return 0

  local acct_id
  acct_id=$(security find-generic-password \
    -s "AWS_ACCOUNT_ID" \
    -a "@kcAccount@" \
    -w "@kcDb@" 2>/dev/null) || return 0

  [[ -z "$acct_id" ]] && return 0

  local expected
  expected=$(@sed@ "s/@placeholder@/$acct_id/g" "@templatePath@")

  if [[ ! -f "$HOME/.aws/config" ]] || [[ "$(cat "$HOME/.aws/config")" != "$expected" ]]; then
    mkdir -p "$HOME/.aws"
    printf '%s\n' "$expected" > "$HOME/.aws/config"
  fi
}
_aws_config_ensure
