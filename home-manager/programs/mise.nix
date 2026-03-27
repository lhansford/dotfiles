_:

{
  home.sessionVariables = {
    MISE_LEGACY_VERSION_FILE = 1;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        node = "24";
      };
      settings = {
        idiomatic_version_file_enable_tools = [
          "python"
          "ruby"
          "terraform"
          "node"
        ];
      };
    };
  };
}
