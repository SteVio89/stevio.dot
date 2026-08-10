{ ... }:

# Interactive-terminal extras: tmux + terminal emulators.
# Composed by the Mac and the Linux desktop; NOT by the headless capsule
# (no display, and — deliberately — no tmux inside the container).
{
  imports = [
    ./apps/tmux.nix
    ./apps/alacritty.nix
    ./apps/ghostty.nix
  ];
}
