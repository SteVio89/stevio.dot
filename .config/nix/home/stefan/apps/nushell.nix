{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = true;
      edit_mode = "vi";
      completions.external.enable = true;
      completions.external.max_results = 200;
      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };
    };

    extraEnv = ''
      # ── Environment variables ──
      $env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
      $env.FZF_DEFAULT_COMMAND = "fd --hidden --exclude .git --strip-cwd-prefix"
      $env.SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib"
      $env.RIPGREP_CONFIG_PATH = ($env.HOME | path join ".config/rg/ripgreprc")

      # ── Homebrew ──
      $env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")

      # ── Dynamic exports ──
      $env.GPG_TTY = (tty)
      $env.SSH_AUTH_SOCK = (launchctl asuser (id -u | str trim) launchctl getenv SSH_AUTH_SOCK | str trim)

      # ── PATH additions not managed by nix ──
      $env.PATH = ($env.PATH | append ($env.HOME | path join ".local/bin"))
      $env.PATH = ($env.PATH | append ($env.HOME | path join "go/bin"))
      $env.PATH = ($env.PATH | prepend "/Users/stefan/Programs/ijhttp")
      $env.PATH = ($env.PATH | prepend "/opt/homebrew/opt/ruby/bin")
      $env.PATH = ($env.PATH | prepend "/opt/homebrew/lib/ruby/gems/3.4.0/bin")

      # ── Google Cloud SDK ──
      let gcloud_bin = "/Users/stefan/Applications/google-cloud-sdk/bin"
      if ($gcloud_bin | path exists) {
        $env.PATH = ($env.PATH | prepend $gcloud_bin)
      }

      # ── ghcup (Haskell) ──
      let ghcup_bin = ($env.HOME | path join ".ghcup/bin")
      if ($ghcup_bin | path exists) {
        $env.PATH = ($env.PATH | prepend $ghcup_bin)
      }

      # ── pnpm ──
      $env.PNPM_HOME = ($env.HOME | path join "Library/pnpm")
      $env.PATH = ($env.PATH | prepend $env.PNPM_HOME)

      # ── Cargo/Rust ──
      let cargo_bin = ($env.HOME | path join ".cargo/bin")
      if ($cargo_bin | path exists) {
        $env.PATH = ($env.PATH | prepend $cargo_bin)
      }

      # ── Nix (prepend so nix-managed binaries take priority) ──
      $env.PATH = ($env.PATH | prepend $"($env.HOME)/.nix-profile/bin")
      $env.PATH = ($env.PATH | prepend $"/etc/profiles/per-user/($env.USER)/bin")
      $env.PATH = ($env.PATH | prepend "/run/current-system/sw/bin")
      $env.PATH = ($env.PATH | prepend "/nix/var/nix/profiles/default/bin")

    '';

    extraConfig = ''
      # Custom commands not expressible as simple shellAliases.
      # See apps/shell-aliases.nix for the simple ones (cat, vim, …).

      def --wrapped dotfiles [...args: string] {
        ^git --git-dir $"($env.HOME)/.dotfiles" --work-tree $env.HOME ...$args
      }

      def cma [] { dotfiles "add" "-u" }

      def cmd [] { dotfiles "diff" "--staged" | ^delta }

      def --wrapped nvim-test [...args: string] {
        with-env { NVIM_APPNAME: "nvim-test" } { ^nvim ...$args }
      }

      def --wrapped ssh [...args: string] {
        with-env { TERM: "xterm-256color" } { ^ssh ...$args }
      }

      def glow [] {
        let file = (^fd -e md | ^fzf --preview 'bat --color=always --style=plain {}' | str trim)
        if ($file | is-not-empty) { ^bat $file }
      }

      # `dev` — minimal devbox replacement on top of plain flake.nix + nix-direnv.
      # Subcommands: init, add, rm, reload.

      def "dev init" [name?: string] {
        if ("flake.nix" | path exists) {
          print "flake.nix already exists — refusing to overwrite"
          return
        }
        let project = ($name | default (pwd | path basename))
        let template = ($env.XDG_CONFIG_HOME | path join "dev-helpers/devshell-flake.nix")
        open $template --raw
          | str replace --all "PROJECT_NAME" $project
          | save flake.nix
        if not (".envrc" | path exists) {
          "use flake\n" | save .envrc
        }
        if not (".gitignore" | path exists) {
          ".direnv/\n" | save .gitignore
        } else if (not (open .gitignore | str contains ".direnv")) {
          "\n.direnv/\n" | save -a .gitignore
        }
        ^direnv allow
      }

      def "dev add" [...pkgs: string] {
        if not ("flake.nix" | path exists) {
          print "no flake.nix — run `dev init` first"
          return
        }
        let marker = "# devhelper:packages"
        let body = (open flake.nix --raw)
        let indent = ($body | lines | where {|l| $l =~ $marker } | get 0 | str replace --regex '#.*' ''')
        let inserted = ($pkgs | each {|p| $"($indent)($p)" } | str join "\n")
        $body | str replace $"($indent)($marker)" $"($inserted)\n($indent)($marker)" | save -f flake.nix
        ^direnv reload
      }

      def "dev rm" [...pkgs: string] {
        if not ("flake.nix" | path exists) {
          print "no flake.nix here"
          return
        }
        let kept = (open flake.nix | lines | where {|l|
          not ($pkgs | any {|p| $l =~ $"^\\s+($p)\\s*$" })
        })
        $kept | str join "\n" | save -f flake.nix
        ^direnv reload
      }

      def "dev reload" [] { ^direnv reload }

      def zsh [] {
        with-env { STAY_ZSH: "1" } {^zsh}
      }
    '';
  };
}
