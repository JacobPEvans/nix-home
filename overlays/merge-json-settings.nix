# Overlay providing merge-json-settings as a proper Nix package.
# Deep-merges Nix-generated JSON settings with existing runtime state.
# Used by activation scripts in nix-home (VS Code) and nix-ai (Claude, Gemini).
_final: prev: {
  merge-json-settings = prev.writeShellApplication {
    name = "merge-json-settings";
    runtimeInputs = [ prev.jq ];
    text = builtins.readFile ../modules/home-manager/scripts/merge-json-settings.sh;
  };
}
