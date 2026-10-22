{
  description = "PROJECT_NAME dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          # Gradle and Maven are pinned to the same JDK so nothing falls back to the nixpkgs default.
          jdk = pkgs.JDK_ATTR;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              jdk
              (gradle.override { java = jdk; })
              (maven.override { jdk_headless = jdk; })
              # devhelper:packages
            ];
            JAVA_HOME = jdk.home;
          };
        }
      );
    };
}
