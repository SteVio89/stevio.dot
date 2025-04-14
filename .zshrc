eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(mcfly init zsh)"
# My autocomplete scripts
fpath=(${ZDOTDIR:-$HOME}/.zsh/completion $fpath)
autoload -Uz compinit
compinit
#source <(fzf --zsh)
#eval "$(navi widget zsh)"


# My aliases
alias nano="nvim"
alias vim="nvim"
alias ll="eza -l -g --icons --git"
alias llt="eza -1 --icons --tree --git-ignore"
alias terraform="tofu"
alias cm="chezmoi"
alias cm+="chezmoi add"
alias cma="chezmoi apply"
alias cme="chezmoi edit"
alias cmd="chezmoi diff"
alias ..="cd .."
alias files="yazi"
alias wfi="caffeinate -d"
alias ktx="kubie ctx"
alias snippets="pet search"
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
#alias find="fd"
#alias mvn="mvnd"

# git aliases
alias pull="git pull"
alias log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

eval "$(starship init zsh)"

# SSH and GPG config
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Exports
if [ -x /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
fi
export PATH="$PATH:/Users/stefan/.local/bin/"
export PATH="$PATH:/Users/stefan/go/bin/"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
export PATH="/Users/stefan/Programs/ijhttp:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
#export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

export EDITOR="$(which nvim)"
export VISUAL="$(which NotepadNext)"
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH="$HOME/.config/rg/ripgreprc"

# ESP32 stuff
#export LIBCLANG_PATH="/Users/stefan/.rustup/toolchains/esp/xtensa-esp32-elf-clang/esp-17.0.1_20240419/esp-clang/lib"
#export PATH="/Users/stefan/.rustup/toolchains/esp/xtensa-esp-elf/esp-13.2.0_20230928/xtensa-esp-elf/bin:$PATH"
# Tools
gpgconf --launch gpg-agent

function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/stefan/Applications/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/stefan/Applications/google-cloud-sdk/completion.zsh.inc'; fi

# source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/tofu tofu

eval "$(direnv hook zsh)"
[ -f "/Users/stefan/.ghcup/env" ] && . "/Users/stefan/.ghcup/env" # ghcup-env
eval "$(zoxide init zsh)"

