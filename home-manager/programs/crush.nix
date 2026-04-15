{ pkgs, ... }:

{
  home = {
    packages = [
      pkgs.nur.repos.charmbracelet.crush
    ];

    sessionVariables = {
      ANTHROPIC_API_KEY = "";
    };

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
        ollama = {
          name = "Ollama (localhost)";
          base_url = "http://localhost:11434/v1";
          type = "openai-compat";
          models = [
            {
              name = "Qwen 3.5 9B";
              id = "qwen3.5:9b";
              context_window = 262144;
              default_max_tokens = 26214;
              can_reason = true;
              reasoning_levels = [
                "low"
                "medium"
                "high"
              ];
              default_reasoning_effort = "medium";
              supports_attachments = true;
            }
            {
              name = "Qwen 3.5 27B";
              id = "qwen3.5:27b";
              context_window = 262144;
              default_max_tokens = 32768;
              can_reason = true;
              reasoning_levels = [
                "low"
                "medium"
                "high"
              ];
              default_reasoning_effort = "medium";
              supports_attachments = true;
            }
          ];
        };
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
