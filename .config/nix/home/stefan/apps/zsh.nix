{ pkgs, lib, ... }:

# macOS-only PATH/brew/gcloud/launchctl wiring lives in apps/zsh-darwin.nix,
# imported by home/stefan/darwin.nix and merged in via mkOrder.
{
  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    syntaxHighlighting.enable = true;

    # Cached compinit; only rebuild dump once per day. `stat -f` is BSD-only —
    # on Linux the command errors, the check falls through to a plain compinit
    # (no daily caching), which is harmless.
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
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      # zsh-vi-mode config (must be set before plugin loads)
      (lib.mkOrder 500 ''
        ZVM_KEYTIMEOUT=0.1
        ZVM_ESCAPE_KEYTIMEOUT=0.01
        ZVM_INIT_MODE=sourcing
      '')

      # `dev` — minimal devbox replacement on top of plain flake.nix + nix-direnv.
      # `dev init [lang] [name]` — optional lang (go/rust/zig/…) seeds packages + a justfile.
      (lib.mkOrder 1700 ''
        # A language may ship its own flake.nix when the shared one cannot express it
        # (rust needs a second input + an overlay). Falls back to the shared template.
        _dev_template() {
          local own="$XDG_CONFIG_HOME/dev-helpers/$1/flake.nix"
          [[ -n "$1" && -f "$own" ]] && { echo "$own"; return }
          echo "$XDG_CONFIG_HOME/dev-helpers/devshell-flake.nix"
        }

        _dev_init() {
          if [[ -f flake.nix ]]; then
            echo "flake.nix already exists — refusing to overwrite" >&2
            return 1
          fi
          local helpers="$XDG_CONFIG_HOME/dev-helpers"
          local lang="$1" name="$2"
          if [[ -n "$lang" && ! -d "$helpers/$lang" ]]; then
            local avail
            avail=$(ls -d "$helpers"/*/ 2>/dev/null | xargs -n1 basename 2>/dev/null | paste -sd, -)
            echo "unknown language: $lang — available: $avail" >&2
            return 1
          fi
          local project="''${name:-''${PWD:t}}"
          local -a seeded=(flake.nix)
          sed "s/PROJECT_NAME/''${project}/g" "$(_dev_template "$lang")" > flake.nix
          if [[ -n "$lang" ]]; then
            _dev_inject_pkgs $(grep -v '^[[:space:]]*$' "$helpers/$lang/packages")
            local f
            for f in "$helpers/$lang"/*(.N); do
              [[ "''${f:t}" == (packages|flake.nix) ]] && continue
              [[ -f "''${f:t}" ]] || { install -m 644 "$f" "''${f:t}"; seeded+=("''${f:t}") }
            done
          fi
          [[ -f .envrc ]] || { echo "use flake" > .envrc; seeded+=(.envrc) }
          if [[ -f .gitignore ]]; then
            grep -q '\.direnv' .gitignore || printf '\n.direnv/\n' >> .gitignore
          else
            echo ".direnv/" > .gitignore
            seeded+=(.gitignore)
          fi
          [[ -d .git ]] || git init -q
          # Nix reads a flake from git, not from disk: untracked files are invisible to
          # `nix develop`, so a fresh repo would fail on its own flake.nix.
          git add -N "''${seeded[@]}" 2>/dev/null
          direnv allow
        }

        # Inject package attrs (one per arg) at the `# devhelper:packages` marker.
        _dev_inject_pkgs() {
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
        }

        _dev_add() {
          if [[ ! -f flake.nix ]]; then
            echo "no flake.nix — run \`dev init\` first" >&2
            return 1
          fi
          _dev_inject_pkgs "$@"
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

        _dev_usage() {
          print -P '
%Bdev%b — flake devshells

  %F{cyan}init%f [lang] [name]  scaffold flake.nix, .envrc, git repo
  %F{cyan}add%f <pkg>...        add packages to flake.nix
  %F{cyan}rm%f <pkg>...         remove packages from flake.nix
'
        }

        dev() {
          case "$1" in
            init) shift; _dev_init "$@" ;;
            add)  shift; _dev_add "$@" ;;
            rm)   shift; _dev_rm "$@" ;;
            "")   _dev_usage ;;
            *)    echo "dev: unknown command '$1'" >&2; _dev_usage >&2; return 2 ;;
          esac
        }
      '')
    ];
  };
}
