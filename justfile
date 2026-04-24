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
  sudo darwin-rebuild switch --flake ~/.config/nix#stevio-dev

update-nix-full:
  nix flake update --flake ~/.config/nix-darwin
  sudo darwin-rebuild switch --flake ~/.config/nix#stevio-dev-full

fix-gpg-agent:
  gpgconf --kill gpg-agent
  gpgconf --launch gpg-agent
  echo "Agent restarted"

setup-secure-enclave-ssh:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Creating Secure Enclave-backed SSH key (Touch ID required)..."
  sc_auth create-ctk-identity -l ssh -k p-256-ne -t bio
  echo ""
  echo "Extracting SSH key handle to ~/.ssh/..."
  cd ~/.ssh
  ssh-keygen -K -w /usr/lib/ssh-keychain.dylib -N ""
  echo ""
  echo "Your public key:"
  cat ~/.ssh/id_ecdsa_sk_rk.pub
  echo ""
  echo "Add this key to GitHub (Settings → SSH keys) and your servers."
