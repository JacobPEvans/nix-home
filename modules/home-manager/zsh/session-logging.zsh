# Terminal session logging
# IMPORTANT: This must be sourced LAST in .zshrc
# The script command takes over the terminal, so everything else must be initialized first

if [ -z "$SCRIPT_SESSION" ]; then
  export SCRIPT_SESSION=1
  mkdir -p ~/logs
  # Clean up terminal logs older than 30 days before starting a new session
  find ~/logs -name "terminal_*.log" -mtime +30 -delete 2>/dev/null
  script -r ~/logs/terminal_$(date +%Y-%m-%d_%H-%M).log
fi
