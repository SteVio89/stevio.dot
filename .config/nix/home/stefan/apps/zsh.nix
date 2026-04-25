{ pkgs, lib, ... }:

# Mac-only: every PATH manipulation, atuin/zvm wiring, gcloud/ghcup/pnpm/cargo
# sourcing, and `exec nu` rely on macOS paths or commands. On Linux today,
# stefan's interactive shell is bash — see home/stefan/linux.nix.
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      strategy = [ "history" "completion" ];
    };

    syntaxHighlighting.enable = true;

    # Cached compinit; only rebuild dump once per day. `stat -f` is BSD-only.
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

    # Simple aliases live in apps/shell-aliases.nix. These need shell-specific
    # syntax (env-var prefix, pipelines, command chaining) so they stay here.
    shellAliases = {
      glow = "fd -e md | fzf --preview 'bat --color=always --style=plain {}' | xargs -r bat";
      nvim-test = "NVIM_APPNAME=nvim-test nvim";
      ".." = "cd ..";
      ssh = "TERM=xterm-256color ssh";
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

      (lib.mkOrder 1650 ''
        if command -v nu &>/dev/null && [[ -z "$STAY_ZSH" ]]; then
          exec nu
        fi
      '')

      # `dev` — minimal devbox replacement on top of plain flake.nix + nix-direnv.
      # Only reached in zsh-only sessions (STAY_ZSH=1); nushell has its own copy.
      (lib.mkOrder 1700 ''
        _dev_template() {
          echo "$XDG_CONFIG_HOME/dev-helpers/devshell-flake.nix"
        }

        _dev_init() {
          if [[ -f flake.nix ]]; then
            echo "flake.nix already exists — refusing to overwrite" >&2
            return 1
          fi
          local project="''${1:-''${PWD:t}}"
          sed "s/PROJECT_NAME/''${project}/g" "$(_dev_template)" > flake.nix
          [[ -f .envrc ]] || echo "use flake" > .envrc
          if [[ -f .gitignore ]]; then
            grep -q '\.direnv' .gitignore || printf '\n.direnv/\n' >> .gitignore
          else
            echo ".direnv/" > .gitignore
          fi
          direnv allow
        }

        _dev_add() {
          if [[ ! -f flake.nix ]]; then
            echo "no flake.nix — run \`dev init\` first" >&2
            return 1
          fi
          local marker='# devhelper:packages'
          local indent
          indent=$(awk -v m="$marker" 'index($0, m) { match($0, /^[ \t]+/); print substr($0, 1, RLENGTH); exit }' flake.nix)
          local tmp
          tmp=$(mktemp)
          awk -v m="$marker" -v ind="$indent" -v pkgs="$*" '
            index($0, m) {
              n = split(pkgs, arr, " ")
              for (i = 1; i <= n; i++) print ind arr[i]
            }
            { print }
          ' flake.nix > "$tmp" && mv "$tmp" flake.nix
          direnv reload
        }

        _dev_rm() {
          if [[ ! -f flake.nix ]]; then
            echo "no flake.nix here" >&2
            return 1
          fi
          local tmp
          tmp=$(mktemp)
          awk -v pkgs="$*" '
            BEGIN { n = split(pkgs, arr, " ") }
            {
              keep = 1
              for (i = 1; i <= n; i++) {
                if ($0 ~ ("^[ \t]+" arr[i] "[ \t]*$")) { keep = 0; break }
              }
              if (keep) print
            }
          ' flake.nix > "$tmp" && mv "$tmp" flake.nix
          direnv reload
        }

        dev() {
          case "$1" in
            init)   shift; _dev_init "$@" ;;
            add)    shift; _dev_add "$@" ;;
            rm)     shift; _dev_rm "$@" ;;
            reload) direnv reload ;;
            *)      echo "usage: dev {init|add|rm|reload} [args...]" >&2; return 2 ;;
          esac
        }
      '')
    ];
  };
}
