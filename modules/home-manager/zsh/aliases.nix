# Shell Aliases
#
# Organized by category. Imported by home.nix for programs.zsh.shellAliases
#
# SUDO REQUIREMENTS:
# - Commands that modify system state (darwin-rebuild) REQUIRE sudo
# - Commands that read/inspect (docker ps, git status) do NOT need sudo
# - User config files (~/.config) should NOT use sudo
#
# Platform: macOS (BSD ls flags used)

{
  # ===========================================================================
  # Directory Listing (macOS/BSD ls)
  # ===========================================================================
  # -a: show hidden files
  # -h: human-readable sizes
  # -l: long format
  # -F: append type indicator (/ for dirs, * for executables)
  # -G: colorized output (macOS BSD ls)
  # -D: date format (macOS BSD ls)
  ll = "ls -ahlFG -D '%Y-%m-%d %H:%M:%S'";
  llt = "ls -ahltFG -D '%Y-%m-%d %H:%M:%S'"; # sorted by time
  lls = "ls -ahlsFG -D '%Y-%m-%d %H:%M:%S'"; # show size
  "ll@" = "ls -@ahlFG -D '%Y-%m-%d %H:%M:%S'"; # show extended attributes (macOS)

  # ===========================================================================
  # Docker (no sudo needed - user in docker group)
  # ===========================================================================
  dps = "docker ps -a"; # List all containers
  dcu = "docker compose up -d"; # Start compose stack detached
  dcd = "docker compose down"; # Stop compose stack

  # ===========================================================================
  # Nix / Darwin
  # ===========================================================================
  # REQUIRES SUDO: darwin-rebuild modifies system-level configurations
  # This activates both system (nix-darwin) and user (home-manager) configs
  # Usage: d-r            # darwin-rebuild switch (standard rebuild)
  d-r = "sudo darwin-rebuild switch --flake .";

  # NO SUDO: Updates flake.lock to latest nixpkgs (must commit before d-r)
  # Usage: nf-u            # update flake in current directory
  nf-u = "nix flake update --flake .";

  # ===========================================================================
  # Python
  # ===========================================================================
  # Use macOS system Python 3 (no sudo needed)
  python = "python3";

  # ===========================================================================
  # Archive (macOS-friendly tar)
  # ===========================================================================
  # COPYFILE_DISABLE=1: don't include macOS resource forks (portable across BSD/GNU tar)
  # --exclude='.DS_Store': skip Finder metadata files
  tgz = "COPYFILE_DISABLE=1 tar --exclude='.DS_Store' -czf";

  # ===========================================================================
  # AWS (aws-vault for credential management)
  # ===========================================================================
  # aws-vault stores credentials in macOS Keychain and provides temporary
  # session credentials to commands. Always use aws-vault exec for AWS CLI.
  #
  # Usage:
  #   av default -- aws s3 ls        # Run command with default profile
  #   av terraform -- terraform plan # Run terraform with specific profile
  #   avl                            # List all profiles in vault
  #   avd aws sts get-caller-identity # Quick check with default profile
  av = "aws-vault exec"; # Execute command with profile credentials
  avl = "aws-vault list"; # List profiles stored in vault
  avd = "aws-vault exec default --"; # Execute with default profile
  ava = "aws-vault add"; # Add new profile credentials to vault
  avr = "aws-vault remove"; # Remove profile from vault

  # ===========================================================================
  # AI CLI Tools (Doppler for secrets injection)
  # ===========================================================================
  # Doppler injects secrets from 'ai-ci-automation' project (prd config):
  #   - GEMINI_API_KEY (Google Gemini - used by PAL MCP)
  #   - OPENROUTER_API_KEY (OpenRouter - unified model access)
  #   - OLLAMA_HOST (Ollama server URL - used by PAL MCP for local models)
  #
  # Usage:
  #   d-claude             # Interactive Claude Code with injected secrets
  #   d-claude -p "prompt" # Non-interactive with prompt
  #
  d-claude = "doppler run -p ai-ci-automation -c prd -- claude";

  # ===========================================================================
  # tmux (session management)
  # ===========================================================================
  ta = "tmux attach -t"; # Attach to named session
  tl = "tmux list-sessions"; # List active sessions
  tn = "tmux new -s"; # Create named session
}
