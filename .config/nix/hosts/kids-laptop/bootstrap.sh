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

BASHRC="$HOME/.bashrc"
ALIAS_LINE='alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"'
if ! grep -qF "$ALIAS_LINE" "$BASHRC" 2>/dev/null; then
  echo "==> persisting 'dotfiles' alias in ~/.bashrc"
  printf '\n# Bare-repo dotfiles management\n%s\n' "$ALIAS_LINE" >> "$BASHRC"
else
  echo "==> 'dotfiles' alias already present in ~/.bashrc"
fi

cat <<EOF

Bootstrap complete.

Flake path: $HOME/.config/nix

Next steps (in a new shell, or after 'source ~/.bashrc'):
  dotfiles pull
  sudo nixos-rebuild switch --flake ~/.config/nix#kids-laptop
EOF
