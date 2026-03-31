{ pkgs, ... }:

{
  imports = [
    ../programs/espanso.nix
    ../programs/ghostty.nix
    ../programs/vscode.nix
  ];

  home.sessionVariables = {
    PERM_PEOPLE_DIR = "$HOME/Obsidian/Personal/people";
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    TRP_API_TOKEN = "op://Personal/todoist-random-project/TRP_API_TOKEN";
    TRP_IGNORED_PROJECTS = "op://Personal/todoist-random-project/TRP_IGNORED_PROJECTS";
  };

  programs.ssh.extraConfig = ''
    Host *
        IdentityAgent ~/.1password/agent.sock
  '';

  home.packages = [
    pkgs.google-chrome
    pkgs.slack

    pkgs.obsidian
    pkgs.fastmail-desktop
    pkgs.discord

    pkgs.nicotine-plus
    pkgs.picard
    pkgs.qbittorrent

    pkgs.junction
  ];
}
