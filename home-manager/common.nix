{ pkgs, ... }:

{
  imports = [
    ./programs/atuin.nix
    ./programs/crush.nix
    ./programs/git.nix
    ./programs/gum.nix
    ./programs/ssh.nix
    ./programs/mise.nix
    ./programs/zsh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  targets.genericLinux.enable = true;

  home = {
    stateVersion = "25.11";

    username = "luke";
    homeDirectory = "/home/luke";

    packages = [
      pkgs.glow
      pkgs.diff-so-fancy
      pkgs.delta
    ];

    file = {
      ".config/git/git_commit_template.txt".source = ../git/git_commit_template.txt;
    };

  };

  programs.home-manager.enable = true;
}
