{ pkgs, ... }:

{
  imports = [
    ./programs/atuin.nix
    ./programs/espanso.nix
    ./programs/ghostty.nix
    ./programs/git.nix
    ./programs/ssh.nix
    ./programs/vscode.nix
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
      pkgs.gum
      pkgs.diff-so-fancy
      pkgs.delta

      pkgs.google-chrome
      pkgs.slack

      pkgs.obsidian
      pkgs.fastmail-desktop
      pkgs.discord

      pkgs.nicotine-plus
      pkgs.picard
    ];

    file = {
      ".config/git/git_commit_template.txt".source = ../git/git_commit_template.txt;
    };

    sessionVariables = {
      EDITOR = "codium";
      GUM_CONFIRM_PROMPT_BACKGROUND = "#2a2a26";
      GUM_CONFIRM_PROMPT_FOREGROUND = "#D0883E";
      GUM_CONFIRM_SELECTED_BACKGROUND = "#4E683E";
      GUM_CONFIRM_SELECTED_FOREGROUND = "#D0D0D2";
      GUM_CONFIRM_UNSELECTED_BACKGROUND = "#767676";
      GUM_CONFIRM_UNSELECTED_FOREGROUND = "#D0D0D2";
      MISE_LEGACY_VERSION_FILE = 1;
      PERM_PEOPLE_DIR = "$HOME/Obsidian/Personal/people";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      TRP_API_TOKEN = "op://Personal/todoist-random-project/TRP_API_TOKEN";
      TRP_IGNORED_PROJECTS = "op://Personal/todoist-random-project/TRP_IGNORED_PROJECTS";
    };
  };

  programs = {
    home-manager.enable = true;

    mise = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
