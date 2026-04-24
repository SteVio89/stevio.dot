#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  cat >&2 <<EOF
usage: $0 <git-remote-url>
example:
  $0 git@github.com:youruser/dotfiles.git
  $0 https://github.com/youruser/dotfiles.git
EOF
  exit 1
fi

REMOTE="$1"
BARE_DIR="$HOME/.dotfiles"
SPARSE_PATHS=(
  ".config/nix/"
  "/justfile"
)

dotfiles() { git --git-dir="$BARE_DIR" --work-tree="$HOME" "$@"; }

if [ -d "$BARE_DIR" ]; then
  echo "==> $BARE_DIR already exists — skipping clone"
else
  echo "==> cloning bare repo from $REMOTE"
  git clone --bare "$REMOTE" "$BARE_DIR"
fi

echo "==> configuring sparse-checkout for: ${SPARSE_PATHS[*]}"
dotfiles config core.sparseCheckout true
mkdir -p "$BARE_DIR/info"
printf "%s\n" "${SPARSE_PATHS[@]}" > "$BARE_DIR/info/sparse-checkout"

echo "==> hiding untracked files in dotfiles status"
dotfiles config status.showUntrackedFiles no

echo "==> checking out sparse paths into \$HOME"
dotfiles checkout -f

cat <<EOF

Bootstrap complete.

Flake path: $HOME/.config/nix

Next steps:
  git --git-dir="\$HOME/.dotfiles" --work-tree="\$HOME" pull
  sudo nixos-rebuild switch --flake ~/.config/nix#kids-laptop

After the rebuild, the 'dotfiles' alias is provided by home-manager
(see home/modules/linux-desktop.nix).
EOF
