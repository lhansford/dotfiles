{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "codium";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles = {
      default = {
        extensions = with pkgs.nix-vscode-extensions.open-vsx; [
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          golang.go
          hashicorp.terraform
          hverlin.mise-vscode
          jnoortheen.nix-ide
          rust-lang.rust-analyzer
          svelte.svelte-vscode
          tamasfe.even-better-toml
          tauri-apps.tauri-vscode
          wayou.vscode-todo-highlight
        ];
        userSettings = {
          "[rust]"."editor.tabSize" = 2;
          "[svelte]"."editor.tabSize" = 2;
          "[svelte]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[typescript]"."editor.tabSize" = 2;
          "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    };
  };
}
