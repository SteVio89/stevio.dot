#!/usr/bin/env bash
set -euo pipefail

HOST="kids-laptop"
FLAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [ "$(id -u)" -ne 0 ]; then
  echo "error: must be run as root (use sudo)." >&2
  exit 1
fi

cat <<EOF
Installing NixOS host '${HOST}' from flake:
  ${FLAKE_ROOT}

Current block devices:
EOF
lsblk
cat <<EOF

disko will partition and format the device defined in
  ${FLAKE_ROOT}/hosts/${HOST}/disko.nix
Everything on that device will be ERASED.

EOF
read -r -p "Type 'yes' to continue: " reply
[ "$reply" = "yes" ] || { echo "aborted."; exit 1; }

echo
echo "==> Running disko (partition + format + mount)"
nix --experimental-features "nix-command flakes" \
  run "github:nix-community/disko/latest" -- \
  --mode disko --flake "${FLAKE_ROOT}#${HOST}"

echo
echo "==> Running nixos-install"
nixos-install --flake "${FLAKE_ROOT}#${HOST}" --no-root-passwd

echo
echo "Done. Remove installer media and reboot."
