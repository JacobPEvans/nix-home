# tmux Configuration
#
# Session persistence, vi keybindings, and remote-friendly settings.
# Enables Claude Code agent teams split-pane mode and remote attach.

{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "tmux-256color";
    escapeTime = 10;
    mouse = true;
    historyLimit = 50000;
    baseIndex = 1;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    sensibleOnTop = true;
    focusEvents = true;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        # Persists pane scrollback to ~/.tmux/resurrect/ (may contain secrets).
        # Acceptable on personal FileVault-encrypted machine for session persistence.
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      yank
    ];

    extraConfig = ''
      # Intuitive splits (inherit current path)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # New window inherits current path
      bind c new-window -c "#{pane_current_path}"

      # Renumber windows on close
      set -g renumber-windows on

      # Aggressive resize (handles mixed-size clients)
      setw -g aggressive-resize on

      # True color support (Tc is the tmux-specific true color flag)
      set -ga terminal-overrides ",*256color*:Tc"

      # Minimal status bar
      set -g status-left " [#S] "
      set -g status-right " #H  %H:%M "
      set -g status-left-length 20
      set -g status-right-length 30
    '';
  };
}
