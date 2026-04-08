{ pkgs, ... }:

{
  home.packages = [
    pkgs.diff-so-fancy
    pkgs.delta
  ];

  home.sessionVariables = {
    DELTA_FEATURES = "diff-so-fancy";
  };
}
