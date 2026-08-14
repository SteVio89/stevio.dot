# stevio.dot

Personal dotfiles for macOS on Apple Silicon.

The repo tree mirrors `$HOME` directly. It is tracked as a **bare repo** in `~/.dotfiles` with `$HOME` as work tree, so there are no symlinks and no install script.

Two layers:

- **nix-darwin + home-manager** (`.config/nix`) manages system settings, packages, shell, tmux, neovim runtime, terminals and the Homebrew list.
- **plain files** (`.config/nvim`, `.config/aerospace`, `.config/zed`, `.gitconfig`, `.ideavimrc`, `Library/Application Support/...`) are checked out as-is by the bare repo.

## Layout

| Path | Purpose |
| --- | --- |
| `.config/nix/flake.nix` | entrypoint, defines `stevio-dev` and `stevio-dev-full` |
| `.config/nix/hosts/stevio-dev/` | per host imports |
| `.config/nix/modules/darwin/` | system config, Homebrew list, macOS defaults |
| `.config/nix/home/stefan/` | home-manager config, apps and aliases |
| `Brewfile` | snapshot from `brew bundle dump`, not the source of truth |
| `justfile` | maintenance recipes |

`stevio-dev` is the daily profile. `stevio-dev-full` is the same host plus `modules/darwin/system-defaults.nix` (dock, finder, trackpad).

## Setup on a new MacBook

Everything assumes user `stefan` and home `/Users/stefan`. Change that in `modules/darwin/base.nix` and `home/stefan/darwin.nix` first if the user differs.

**1. Command line tools**

```sh
xcode-select --install
```

**2. Check out the dotfiles**

```sh
git clone --bare https://github.com/SteVio89/stevio.dot.git "$HOME/.dotfiles"
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" config status.showUntrackedFiles no
```

If checkout aborts because a file already exists (usually `.zprofile`), move that file aside and run the checkout again.

**3. Install Nix**

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new shell afterwards.

**4. Install Homebrew**

nix-darwin manages the package list but does not install brew itself, so this step is required before the first build.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**5. First build**

`just` is not available yet, so call nix directly:

```sh
sudo -i nix run nix-darwin -- switch --flake ~/.config/nix#stevio-dev-full
```

Existing files that home-manager wants to own are renamed to `*.backup` instead of being overwritten.

**6. Restart the shell** and verify with `just -l`.

## After the first build

- **GPG**: import the private key and trust it, then check `git config --get user.signingKey` matches. Signing uses `/opt/homebrew/bin/gpg` with `pinentry-mac`.
- **SSH key in the Secure Enclave** (Touch ID):

  ```sh
  just setup-secure-enclave-ssh
  ```

  Then add the printed public key to GitHub and to your servers.

- **Quarantined apps**: `just fix-app /Applications/Some.app`

## Daily use

```sh
just update-nix        # flake update + rebuild stevio-dev
just update-nix-full   # same, with macOS defaults
just update-brewfile   # refresh the Brewfile snapshot
just clean-brew        # autoremove, cleanup, bundle cleanup
just space             # disk usage (dua)
just fix-gpg-agent     # restart gpg-agent
```

Tracking changes uses the `dotfiles` alias from `home/stefan/apps/shell-aliases.nix`:

```sh
dotfiles status
cma                    # dotfiles add -u
cmd                    # staged diff through delta
dotfiles commit -m "..."
dotfiles push
```

New files need an explicit `dotfiles add <path>`, since untracked files are hidden.

## Notes

- Adding a brew package means editing `modules/darwin/homebrew.nix` and rebuilding. The root `Brewfile` is only a dump.
- `onActivation.cleanup` is `"none"`. Not set it to `"zap".
- The flake pins `github:SteVio89/capsule` and `github:agavra/tuicr` as inputs.
