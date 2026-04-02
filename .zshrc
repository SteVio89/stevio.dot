eval "$(/opt/homebrew/bin/brew shellenv)"
export XDG_CONFIG_HOME="$HOME/.config"
# fpath=(${ZDOTDIR:-$HOME}/.zsh/completion $fpath)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source <(fzf --zsh)
source /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git --strip-cwd-prefix'
zvm_after_init_commands+=(eval "$(atuin init zsh)")


# My aliases
alias cat="bat"
alias nano="nvim"
alias vim="nvim"
alias vi="nvim"
alias nvim-test="NVIM_APPNAME=nvim-test nvim"
alias cma="dotfiles add -u"
alias cmd="dotfiles diff --staged | delta"
alias ..="cd .."
alias wfi="caffeinate -d"
alias ktx="kubie ctx"
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias replace="rgr"
alias ssh="TERM=xterm-256color ssh"
alias ff="cdi"
alias setup_dev="devbox init && devbox generate direnv && direnv allow"

eval "$(starship init zsh)"

# SSH and GPG config
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(launchctl asuser $(id -u) launchctl getenv SSH_AUTH_SOCK)

export PATH="$PATH:/Users/stefan/.local/bin/"
export PATH="$PATH:/Users/stefan/go/bin/"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Users/stefan/Programs/ijhttp:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$VCPKG_ROOT:$PATH"

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="/opt/homebrew/share/zsh-syntax-highlighting/highlighters"
export EDITOR="nvim"
export VISUAL="nvim"
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgreprc"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc'; fi

# bashcompinit runs in /etc/zshrc via nix-darwin

eval "$(direnv hook zsh)"
[ -f "/Users/stefan/.ghcup/env" ] && . "/Users/stefan/.ghcup/env" # ghcup-env

eval "$(zoxide init zsh --cmd cd)"

# pnpm
export PNPM_HOME="/Users/stefan/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

