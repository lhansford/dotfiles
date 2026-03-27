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
    ];
  };
}
