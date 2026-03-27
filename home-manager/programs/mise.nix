{ ... }:

{
  home.sessionVariables = {
    MISE_LEGACY_VERSION_FILE = 1;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
}
