{ pkgs, ... }:

let
  todoistToken = builtins.readFile ./secrets/todoist-token;
in
{
  programs.vicinae = {
    enable = true;
  };

  home = {
    file = {
      ".local/share/vicinae/scripts/todoist-quick-add.sh" = {
        source = pkgs.replaceVars ../../vicinae-scripts/todoist-quick-add.sh {
          TODOIST_API_TOKEN = todoistToken;
        };
        executable = true;
      };
    };
  };
}
