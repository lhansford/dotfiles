{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
      "rust-analyzer-lsp@claude-plugins-official" = true;
    };
    model = "opus[1m]";
  };
}
