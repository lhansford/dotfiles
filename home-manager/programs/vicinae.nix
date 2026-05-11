{ pkgs, ... }:

{
  programs.vicinae = {
    enable = true;
  };

  home = {
    file = {
      ".local/share/vicinae/scripts/todoist-quick-add.sh".source = ../../vicinae-scripts/todoist-quick-add.sh;
    };
  };
}
