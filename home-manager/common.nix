{ pkgs, ... }:

{
  imports = [
    ./programs/atuin.nix
    ./programs/crush.nix
    ./programs/delta.nix
    ./programs/fzf.nix
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
    ];

    file = {
      ".config/git/git_commit_template.txt".source = ../git/git_commit_template.txt;
      ".local/bin/dff".source = ../bin/dff;
    };

    sessionPath = [
      "~/.local/bin"
    ];
  };

  programs.home-manager.enable = true;
}
