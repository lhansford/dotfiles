{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "codium";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.nix-vscode-extensions.open-vsx; [
      hashicorp.terraform
      jnoortheen.nix-ide
      esbenp.prettier-vscode
      hverlin.mise-vscode
      golang.go
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      wayou.vscode-todo-highlight
    ];
  };
}
