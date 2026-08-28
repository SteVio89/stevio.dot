{ lib, ... }:

# macOS-only zsh wiring, split out of apps/zsh.nix: every PATH manipulation,
# Homebrew shellenv, gcloud/ghcup/pnpm/cargo sourcing, and the launchctl-derived
# SSH_AUTH_SOCK rely on macOS paths or commands. Imported only by home/stefan/darwin.nix.
# Merged into programs.zsh.initContent via mkOrder (same order values as before).
{
  programs.zsh.initContent = lib.mkMerge [
    # Early: brew shellenv (must come before most things).
    # Cached to disk because `brew shellenv` forks ruby and can stall on
    # Homebrew's global lock — that stall ignores SIGINT and was the root
    # cause of the "frozen cursor on shell start" hang. TTL: 24 h.
    # Cache freshness check uses zsh glob qualifier (N.m-1) instead of `find`
    # so the common path (cache fresh) does zero forks.
    (lib.mkOrder 550 ''
      export HOMEBREW_NO_AUTO_UPDATE=1
      export HOMEBREW_NO_ANALYTICS=1

      __brew_cache="$HOME/.cache/brew-shellenv.zsh"
      # (N.m-1) → array has 1 element iff file exists, is regular, mtime < 1 day
      __cached_fresh=("$__brew_cache"(N.m-1))
      if (( ''${#__cached_fresh} == 0 )); then
        [[ -d "''${__brew_cache:h}" ]] || mkdir -p "''${__brew_cache:h}"
        /opt/homebrew/bin/brew shellenv > "$__brew_cache"
      fi
      source "$__brew_cache"
      unset __brew_cache __cached_fresh
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

    # Nix PATH (should be last PATH manipulation)
    (lib.mkOrder 1600 ''
      export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
    '')
  ];
}
