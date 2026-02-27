# Terminal session logging
# IMPORTANT: This must be sourced LAST in .zshrc
# The script command takes over the terminal, so everything else must be initialized first

if [ -z "$SCRIPT_SESSION" ]; then
  export SCRIPT_SESSION=1
  mkdir -p ~/logs
  script -r ~/logs/terminal_$(date +%Y-%m-%d_%H-%M).log
fi
