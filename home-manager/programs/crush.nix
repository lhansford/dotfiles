{ pkgs, ... }:

{
  home = {
    packages = [
      pkgs.nur.repos.charmbracelet.crush
    ];

    file.".config/crush/crush.json".text = builtins.toJSON {
      "$schema" = "https://charm.land/crush.json";
      options = {
        context_paths = [
          "/home/luke/.config/AGENTS.md"
        ];
      };
      permissions = {
        allowed_tools = [
          "agentic_fetch"
          "diff"
          "edit"
          "grep"
          "ls"
          "multiedit"
          "view"
          "write"
        ];
      };

      hooks = {
        PreToolUse = [
          {
            matcher = "^bash$";
            command = "./rtk-rewrite.sh";
          }
        ];
      };
    };
  };
}
