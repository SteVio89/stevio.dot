{ lib, ... }:

{
  programs.zsh.initContent = lib.mkOrder 1750 ''
    docs() {
      CONTEXT7_API_KEY="$(security find-generic-password -a "$USER" -s context7-api-key -w)" \
      GOOSE_MOIM_MESSAGE_TEXT="Call resolve-library-id, then query-docs. Never answer from memory. If query-docs returns nothing relevant, say so and stop. Always state the library version." \
      GOOSE_MODE="approve" \
      goose run --recipe "$XDG_CONFIG_HOME/goose/recipes/fetch-docs.yaml" --interactive --params question="$*"
    }

    opts() {
      GOOSE_MOIM_MESSAGE_TEXT="Approaches only, no code. Do not recommend one unless asked. Flag if your knowledge may be outdated." \
      goose run --recipe "$XDG_CONFIG_HOME/goose/recipes/show-options.yaml" --interactive --params question="$*"
    }
  '';
}
