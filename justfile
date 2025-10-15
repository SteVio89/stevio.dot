# List available commands
default:
    just -l
# Open disk analyzer
space:
    dua i

restart-gpg:
  gpgconf --kill gpg-agent

# update-yabai:
#   echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
#
# restart-desktop:
#   yabai --restart-service
#   brew services restart sketchybar

update-brewfile:
  rm /Users/stefan/Brewfile
  brew bundle dump --file /Users/stefan/Brewfile

clean-brew:
  brew autoremove
  brew cleanup --prune=all
  brew bundle cleanup
  echo "Run 'brew bundle cleanup --force' to actually cleanup"
