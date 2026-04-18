{ ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/pi4.nix
    ../modules/kiosk.nix
    ../modules/wifi.nix
  ];

  networking.hostName = "lotus";

  kiosk.url = "http://kraftwerk:8080/";

  boot.kernelParams = [ "video=HDMI-A-1:D" ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.luke = import ../../home-manager/hosts/lotus.nix;
  };
}
