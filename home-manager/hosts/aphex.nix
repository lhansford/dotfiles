{ lib, ... }:

{
  imports = [
    ../environments/graphical.nix
  ];

  home.sessionVariables = {
    LD_LIBRARY_PATH = "/usr/lib:/usr/lib32:$LD_LIBRARY_PATH";
  };

  programs.git.signing.key = lib.removeSuffix "\n" (builtins.readFile ../../keys/aphex.pub);
}
