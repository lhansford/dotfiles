{ pkgs, ... }:

{
  imports = [
    ../environments/fishbrain.nix
    ../programs/claude-code.nix
    ../programs/crush.nix
    ../programs/espanso.nix
    ../programs/flameshot.nix
    ../programs/ghostty.nix
    ../programs/vscode.nix
  ];

  home = {
    file = {
      ".local/bin/open".source = ../../bin/open;
    };
    packages = [
      pkgs.google-chrome
      pkgs.slack

      pkgs.obsidian
      pkgs.fastmail-desktop
      pkgs.discord

      pkgs.picard
      pkgs.qbittorrent

      pkgs.ly

      pkgs.dbeaver-bin
    ];
    sessionVariables = {
      PERM_PEOPLE_DIR = "$HOME/Obsidian/Personal/people";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };
  };

  programs.ssh.extraConfig = ''
    Host *
        IdentityAgent ~/.1password/agent.sock
  '';

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = "re.sonny.Junction.desktop";
        "x-scheme-handler/https" = "re.sonny.Junction.desktop";
        "text/html" = "re.sonny.Junction.desktop";
      };
    };

    dataFile."applications/google-chrome.desktop".source =
      "${pkgs.google-chrome}/share/applications/google-chrome.desktop";
  };
}
