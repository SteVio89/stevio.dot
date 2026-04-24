## System install

1. Boot laptop with nixos-minimal-<VERSION>-x86_64-linux.iso
2. sudo loadkeys de
3. sudo systemctl start NetworkManager
4. nmtui -> wifi setup
5. cd /tmp
6. git clone https://github.com/SteVio89/stevio.dot.git
7. run lsblk to check disk config
8. cd /tmp/stevio.dot.git/.config/nix
9. sudo nixos-generate-config --show-hardware-config --no-filesystems > hosts/kids-laptop/hardware-configuration.nix
10. sudo bash hosts/kids-laptop/install.sh
11. sudo reboot

## System first boot setup

1. login as stefan
2. nmtui -> wifi setup
3. curl -LO https://raw.githubusercontent.com/SteVio89/stevio.dot/refs/heads/main/.config/nix/hosts/kids-laptop/bootstrap.sh
4. ssh-keygen -t ed25519 -C "kids-laptop" -f ~/.ssh/id_ed25519 -N ""
5. cat ~/.ssh/id_ed25519.pub
4. bash bootstrap.sh git@github.com:SteVio89/stevio.dot.git
5. source ~/.bashrc
6. sudo nixos-generate-config --show-hardware-config --no-filesystems > ~/.config/nix/hosts/kids-laptop/hardware-configuration.nix
7. dotfiles add .config/nix/hosts/kids-laptop/hardware-configuration.nix
8. dotfiles commit -m "kids-laptop: hardware-configuration from first install"
9. dotfiles push
