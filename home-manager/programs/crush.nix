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
      providers = {
        anthropic = { };
      };
      models = {
        large = {
          model = "claude-opus-4-6";
          provider = "anthropic";
          reasoning_effort = "medium";
          max_tokens = 126000;
        };
        small = {
          model = "claude-sonnet-4-6";
          provider = "anthropic";
          reasoning_effort = "medium";
          max_tokens = 64000;
        };
      };
      recent_models = {
        large = [
          {
            model = "claude-opus-4-6";
            provider = "anthropic";
          }
          {
            model = "claude-sonnet-4-6";
            provider = "anthropic";
          }
        ];
        small = [
          {
            model = "claude-sonnet-4-6";
            provider = "anthropic";
          }
        ];
      };
    };
  };
}
