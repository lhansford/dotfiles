{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "codium";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Terraform
      hashicorp.terraform
      # Nix
      jnoortheen.nix-ide
      # JS/TS
      esbenp.prettier-vscode
      # Go
      golang.go
      # Rust
      rust-lang.rust-analyzer
      # TOML
      tamasfe.even-better-toml
    ];
  };
}
