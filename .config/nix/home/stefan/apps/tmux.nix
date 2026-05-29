{ pkgs, ... }:
let
  autotile = pkgs.writeShellApplication {
    name = "tmux-autotile";
    runtimeInputs = [ pkgs.gnugrep ];
    text = ''
      active=80   # percent for the focused top-row pane; neighbour gets 100-active

      apply() {
        [ "$(tmux show -gv @autotile 2>/dev/null)" = "on" ] || return 0
        # only act when the focused pane is in the top row, never the terminal
        [ "$(tmux display-message -p '#{pane_top}')" = "0" ] || return 0
        # and only when there is actually a neighbour to give the space to
        [ "$(tmux list-panes -F '#{pane_top}' | grep -c '^0$' || true)" -ge 2 ] || return 0
        tmux resize-pane -x "''${active}%"
      }

      case "''${1:-apply}" in
        toggle)
          if [ "$(tmux show -gv @autotile 2>/dev/null)" = "on" ]; then
            tmux set -g @autotile off
            tmux display-message "auto-tile: OFF (sizes frozen)"
          else
            tmux set -g @autotile on
            tmux display-message "auto-tile: ON"
            apply   # take effect immediately on the currently focused pane
          fi
          ;;
        *) apply ;;
      esac
    '';
  };
in
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 50000;
    terminal = "tmux-256color";
    mouse = true;
    focusEvents = true;
    prefix = "S-F3";
    escapeTime = 10;
    customPaneNavigationAndResize = true;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour mocha
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_text " #{b:pane_current_path} #{pane_current_command}"
          set -g @catppuccin_window_default_text " #{b:pane_current_path} #{pane_current_command}"
          set -g @catppuccin_window_current_text " #{b:pane_current_path} #{pane_current_command}"

          # Must be set before prefix-highlight runs (it does string replacement, not a tmux format)
          set -g status-left " #{prefix_highlight}"
          set -g status-left-length 100
          set -g status-right "session: #{session_name} #{E:@catppuccin_status_application} "
          set -g status-right-length 100
        '';
      }
      prefix-highlight
    ];

    extraConfig = ''
      bind-key S-F3 send-prefix
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
      bind % split-window -h -c '#{pane_current_path}'
      bind '"' split-window -v -c '#{pane_current_path}'

      set -g @autotile off
      set-hook -g pane-focus-in 'run-shell -b "${autotile}/bin/tmux-autotile apply"'
      bind a run-shell "${autotile}/bin/tmux-autotile toggle"
    '';
  };
}
