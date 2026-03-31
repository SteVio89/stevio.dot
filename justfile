default:
    just -l

space:
    dua i

restart-gpg:
  gpgconf --kill gpg-agent

fix-app *app:
  xattr -rd com.apple.quarantine /Applications/{{app}}.app

update-brewfile:
  rm /Users/stefan/Brewfile
  brew bundle dump --file /Users/stefan/Brewfile

clean-brew:
  brew autoremove
  brew cleanup --prune=all
  brew bundle cleanup
  echo "Run 'brew bundle cleanup --force' to actually cleanup"

export-gpg:
  gpg --output public_stefan_viol.pgp --armor --export stefan@stevio.de

init-nix:
  sudo -i nix run nix-darwin -- switch --flake /Users/stefan/.config/nix-darwin

update-nix:
  nix flake update --flake ~/.config/nix-darwin
  darwin-rebuild build --flake ~/.config/nix-darwin
  sudo ./result/activate

init-nix:
  darwin-rebuild build --flake ~/.config/nix-darwin
  sudo ./result/activate
