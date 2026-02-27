# VS Code Writable Configuration
#
# Returns { activation } for deep-merging Nix settings into writable files.
# Replaces home-manager's read-only symlink approach so VS Code can write
# runtime changes (extension settings, theme, workspace preferences).
#
# On each darwin-rebuild switch, Nix settings are deep-merged on top of
# existing runtime state: Nix wins on conflicts, runtime-only keys preserved.
#
# Pattern matches gemini.nix — see merge-json-settings.sh for merge logic.

{
  config,
  lib,
  pkgs,
}:

let
  # Import settings modules
  generalSettings = import ./settings.nix { inherit config; };
  copilotSettings = import ./copilot-settings.nix { };
  mcpSettings = import ./mcp.nix;

  # Combined VS Code settings (matches what HM module previously generated)
  # Includes update.mode and extensions.autoCheckUpdates that were previously
  # injected by enableUpdateCheck/enableExtensionUpdateCheck options
  settings = {
    "editor.formatOnSave" = true;
    "update.mode" = "none";
    "extensions.autoCheckUpdates" = false;
  }
  // generalSettings
  // copilotSettings;

  # Generate pretty-printed JSON via derivation
  settingsJson =
    pkgs.runCommand "vscode-settings.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
        json = builtins.toJSON settings;
        passAsFile = [ "json" ];
      }
      ''
        jq '.' "$jsonPath" > $out
      '';

  mcpJson =
    pkgs.runCommand "vscode-mcp.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
        json = builtins.toJSON mcpSettings;
        passAsFile = [ "json" ];
      }
      ''
        jq '.' "$jsonPath" > $out
      '';

  homeDir = config.home.homeDirectory;

  # Platform-aware VS Code config directory (relative to home)
  vscodeConfigDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Code/User"
    else
      ".config/Code/User";

  mergeScript = ../scripts/merge-json-settings.sh;
  jqExe = lib.getExe pkgs.jq;
in
{
  activation = {
    mergeVscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${mergeScript} \
        "${settingsJson}" \
        "${homeDir}/${vscodeConfigDir}/settings.json" \
        "${jqExe}"
    '';

    mergeVscodeMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${mergeScript} \
        "${mcpJson}" \
        "${homeDir}/${vscodeConfigDir}/mcp.json" \
        "${jqExe}"
    '';
  };
}
