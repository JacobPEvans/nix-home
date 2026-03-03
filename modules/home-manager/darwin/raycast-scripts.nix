# Raycast Script Scheduling
#
# Manages LaunchAgents for Raycast helper scripts.
# Replaces manual plist files with declarative Nix management.
# Script at ~/.config/raycast/scripts/refresh-repos.sh is managed by Raycast.
{ config, lib, ... }:
let
  homeDir = config.home.homeDirectory;
  scriptPath = "${homeDir}/.config/raycast/scripts/refresh-repos.sh";
  logPath = "${homeDir}/Library/Logs/com.jacobpevans.refresh-smart-issue-repos.log";
in
{
  options.programs.raycast-scripts = {
    refreshRepos = {
      enable = lib.mkEnableOption "hourly Raycast repo list refresh";
    };
  };

  config = lib.mkIf config.programs.raycast-scripts.refreshRepos.enable {
    launchd.agents.refresh-smart-issue-repos = {
      enable = true;
      config = {
        Label = "com.jacobpevans.refresh-smart-issue-repos";
        ProgramArguments = [ scriptPath ];
        RunAtLoad = true;
        StartInterval = 3600;
        StandardOutPath = logPath;
        StandardErrorPath = logPath;
        EnvironmentVariables = {
          HOME = homeDir;
          PATH = lib.concatStringsSep ":" [
            "/etc/profiles/per-user/${config.home.username}/bin"
            "/run/current-system/sw/bin"
            "/nix/var/nix/profiles/default/bin"
            "/usr/bin"
            "/bin"
          ];
        };
      };
    };
  };
}
