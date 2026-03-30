eval "$(/opt/homebrew/bin/brew shellenv)"
export XDG_CONFIG_HOME="$HOME/.config"
# My autocomplete scripts
fpath=(${ZDOTDIR:-$HOME}/.zsh/completion $fpath)

autoload -Uz compinit
compinit
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source <(fzf --zsh)
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

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

eval "$(starship init zsh)"

# SSH and GPG config
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

if [ -x /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
fi
export PATH="$PATH:/Users/stefan/.local/bin/"
export PATH="$PATH:/Users/stefan/go/bin/"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Users/stefan/Programs/ijhttp:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$VCPKG_ROOT:$PATH"

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="/opt/homebrew/share/zsh-syntax-highlighting/highlighters"
export EDITOR="$(which nvim)"
export VISUAL="$(which nvim)"
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgreprc"

# Tools
gpgconf --launch gpg-agent

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc'; fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/tofu tofu

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
