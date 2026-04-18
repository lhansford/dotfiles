{ lib, ... }:

{
  imports = [
    ../common.nix
  ];

  targets.genericLinux.enable = lib.mkForce false;
}
