{ pkgs, lib, ... }: {
  programs.zsh = {
        enable = true;

        autosuggestion = {
          enable = true;
          strategy = [ "history" "completion" ];
        };

        syntaxHighlighting.enable = true;

        # Use cached compinit; only rebuild dump once per day
        completionInit = ''
          autoload -U compinit
          if [[ -f "$HOME/.zcompdump" && $(date +'%j') == $(stat -f '%Sm' -t '%j' "$HOME/.zcompdump" 2>/dev/null) ]]; then
            compinit -C
          else
            compinit
          fi
        '';

        history = {
          size = 50000;
          save = 50000;
          ignoreDups = true;
          share = true;
        };

        shellAliases = {
          glow = "fd -e md | fzf --preview 'bat --color=always --style=plain {}' | xargs -r bat";
          cat = "bat";
          nano = "nvim";
          vim = "nvim";
          vi = "nvim";
          nvim-test = "NVIM_APPNAME=nvim-test nvim";
          cma = "dotfiles add -u";
          cmd = "dotfiles diff --staged | delta";
          ".." = "cd ..";
          wfi = "caffeinate -d";
          ktx = "kubie ctx";
          dotfiles = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
          replace = "rgr";
          ssh = "TERM=xterm-256color ssh";
          ff = "cdi";
          cb = "pbcopy";
          setup_dev = "devbox init && devbox generate direnv && direnv allow";
        };

        sessionVariables = {
          XDG_CONFIG_HOME = "$HOME/.config";
          FZF_DEFAULT_COMMAND = "fd --hidden --exclude .git --strip-cwd-prefix";
          SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib";
          RIPGREP_CONFIG_PATH = "$HOME/.config/rg/ripgreprc";
        };

        plugins = [
          {
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
        ];

        initContent = lib.mkMerge [
          # zsh-vi-mode config (must be set before plugin loads)
          (lib.mkOrder 500 ''
            ZVM_KEYTIMEOUT=0.1
            ZVM_ESCAPE_KEYTIMEOUT=0.01
          '')

          # Early: brew shellenv (must come before most things)
          (lib.mkOrder 550 ''
            eval "$(/opt/homebrew/bin/brew shellenv)"
          '')

          # After plugins init: atuin with zvm integration
          (lib.mkOrder 1050 ''
            zvm_after_init_commands+=(eval "$(atuin init zsh)")
          '')

          # Dynamic exports that cannot be sessionVariables
          (lib.mkOrder 1100 ''
            export GPG_TTY="$(tty)"
            export SSH_AUTH_SOCK=$(launchctl asuser $(id -u) launchctl getenv SSH_AUTH_SOCK)
          '')

          # PATH additions not managed by nix
          (lib.mkOrder 1200 ''
            export PATH="$PATH:/Users/stefan/.local/bin/"
            export PATH="$PATH:/Users/stefan/go/bin/"
            export PATH="/opt/homebrew/bin:$PATH"
            export PATH="/Users/stefan/Programs/ijhttp:$PATH"
            export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
            export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
            export PATH="$VCPKG_ROOT:$PATH"
          '')

          # Google Cloud SDK
          (lib.mkOrder 1300 ''
            if [ -f '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc' ]; then
              . '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc'
            fi
            if [ -f '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc' ]; then
              . '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc'
            fi
          '')

          # ghcup
          (lib.mkOrder 1400 ''
            [ -f "/Users/stefan/.ghcup/env" ] && . "/Users/stefan/.ghcup/env"
          '')

          # pnpm
          (lib.mkOrder 1500 ''
            export PNPM_HOME="/Users/stefan/Library/pnpm"
            case ":$PATH:" in
              *":$PNPM_HOME:"*) ;;
              *) export PATH="$PNPM_HOME:$PATH" ;;
            esac
          '')

          # Cargo/Rust
          (lib.mkOrder 1550 ''
            [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
          '')

          # Nix PATH (should be last PATH manipulation)
          (lib.mkOrder 1600 ''
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
          '')
        ];
      };
}
