# Daily Log Cleanup LaunchAgent
#
# Removes stale log files, caches, and Claude artifacts on a daily schedule.
# Runs at 3 AM every day. Nix profile history wipe runs only on Sundays.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  logPath = "${homeDir}/Library/Logs/log-cleanup.log";

  cleanupScript = pkgs.writeShellScript "log-cleanup" ''
    set -uo pipefail

    log() {
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    }

    log "Starting daily log cleanup"

    # Delete ~/logs/terminal_*.log older than 30 days
    if [ -d "${homeDir}/logs" ]; then
      find "${homeDir}/logs" -name 'terminal_*.log' -type f -mtime +30 -delete \
        && log "Cleaned terminal logs older than 30 days"
    fi

    # Delete ~/.claude/debug/* older than 7 days
    if [ -d "${homeDir}/.claude/debug" ]; then
      find "${homeDir}/.claude/debug" -mindepth 1 -type f -mtime +7 -delete \
        && log "Cleaned .claude/debug older than 7 days"
    fi

    # Delete ~/.claude/logs/* older than 14 days
    if [ -d "${homeDir}/.claude/logs" ]; then
      find "${homeDir}/.claude/logs" -mindepth 1 -type f -mtime +14 -delete \
        && log "Cleaned .claude/logs older than 14 days"
    fi

    # Delete ~/.claude/plans/* older than 30 days
    if [ -d "${homeDir}/.claude/plans" ]; then
      find "${homeDir}/.claude/plans" -mindepth 1 -type f -mtime +30 -delete \
        && log "Cleaned .claude/plans older than 30 days"
    fi

    # Clear ~/Library/Caches/Mozilla.sccache/* older than 14 days
    if [ -d "${homeDir}/Library/Caches/Mozilla.sccache" ]; then
      find "${homeDir}/Library/Caches/Mozilla.sccache" -mindepth 1 -type f -mtime +14 -delete \
        && log "Cleaned Mozilla.sccache older than 14 days"
    fi

    # Clear ~/Library/Caches/terragrunt/* older than 30 days
    if [ -d "${homeDir}/Library/Caches/terragrunt" ]; then
      find "${homeDir}/Library/Caches/terragrunt" -mindepth 1 -type f -mtime +30 -delete \
        && log "Cleaned terragrunt cache older than 30 days"
    fi

    # Clear ~/Library/Caches/pip/* older than 30 days
    if [ -d "${homeDir}/Library/Caches/pip" ]; then
      find "${homeDir}/Library/Caches/pip" -mindepth 1 -type f -mtime +30 -delete \
        && log "Cleaned pip cache older than 30 days"
    fi

    # Wipe nix profile history older than 30 days — only on Sundays (date +%u = 7)
    if [ "$(date +%u)" = "7" ]; then
      log "Sunday: running nix profile wipe-history --older-than 30d"
      nix profile wipe-history --older-than 30d \
        && log "Nix profile history wiped" || true
    fi

    log "Daily log cleanup complete"
  '';
in
{
  options.programs.log-cleanup = {
    enable = lib.mkEnableOption "daily log and cache cleanup LaunchAgent";
  };

  config = lib.mkIf config.programs.log-cleanup.enable {
    launchd.agents.log-cleanup = {
      enable = true;
      config = {
        Label = "com.jacobpevans.log-cleanup";
        ProgramArguments = [ "${cleanupScript}" ];
        StartCalendarInterval = [
          {
            Hour = 3;
            Minute = 0;
          }
        ];
        StandardOutPath = logPath;
        StandardErrorPath = logPath;
        EnvironmentVariables = {
          HOME = homeDir;
          PATH = lib.concatStringsSep ":" [
            "/etc/profiles/per-user/${config.home.username}/bin"
            "/run/current-system/sw/bin"
            "/nix/var/nix/profiles/default/bin"
            "/usr/local/bin"
            "/usr/bin"
            "/bin"
          ];
        };
      };
    };
  };
}
