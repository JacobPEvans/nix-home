# macOS-Specific Home-Manager Modules
#
# User-level modules that use macOS-only APIs (LaunchAgents, osascript, etc.)
# Imported unconditionally in flake.nix (no platform guard).
#
# These modules are safe cross-platform because:
# - They define options with mkEnableOption (defaults to false)
# - Config sections are gated with mkIf + stdenv.isDarwin
# - No macOS-specific code runs unless the option is explicitly enabled on Darwin

{
  imports = [
    ./raycast-scripts.nix
    ./nix-activation-recovery.nix
  ];
}
