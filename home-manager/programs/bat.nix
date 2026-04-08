_:

{
  programs.bat = {
    enable = true;
  };

  home.sessionVariables = {
    # Although this can be configured in programs.bat, we set it as an env var so that delta can also use it.
    BAT_THEME = "zenburn";
  };
}
