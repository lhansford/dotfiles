_:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {

      theme = "skogen";

      font-family = "Inconsolata Nerd Font Mono Regular";
      font-family-bold = "Inconsolata Nerd Font Mono Bold";
      background-opacity = 0.9;
      background-blur-radius = 16;

      adjust-cursor-thickness = 3;

      keybind = [
        "control+w=close_surface"
        "control+q=quit"
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
        "ctrl+t=new_tab"
        "ctrl+down=new_split:down"
        "ctrl+right=new_split:right"
        "ctrl+1=goto_tab:1"
        "ctrl+2=goto_tab:2"
        "ctrl+3=goto_tab:3"
        "ctrl+4=goto_tab:4"
        "ctrl+5=goto_tab:5"
        "ctrl+6=goto_tab:6"
        "ctrl+7=goto_tab:7"
        "ctrl+8=goto_tab:8"
        "ctrl+9=goto_tab:9"
        "ctrl+0=goto_tab:10"
      ];

      font-size = 10;

      shell-integration-features = "ssh-terminfo,ssh-env";
    };

    themes = {
      skogen = {
        palette = [
          "1=#E25E3E"
          "2=#7D9863"
          "3=#D0883E"
          "4=#176B87"
          "5=#B0578D"
          "8=#555555"
          "9=#DF7861"
          "10=#4E683E"
          "11=#FF8445"
          "12=#72D8FD"
          "13=#fd28ff"
        ];
        background = "2a2a26";
        foreground = "D0D0D2";
        cursor-color = "4E683E";
        selection-background = "FFF7D0";
        selection-foreground = "2a2a26";
      };
    };
  };
}
