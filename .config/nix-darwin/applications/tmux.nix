{ pkgs, ... }: {
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
    '';
  };
}
