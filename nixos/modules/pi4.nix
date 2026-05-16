{ pkgs, ... }:

{
  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
  };

  # nixos-hardware's raspberry-pi-4 defaults to linux_rpi4, but sd-image-aarch64
  # assumes mainline (it requests modules like dw-hdmi that linux_rpi4 omits).
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "consoleblank=0" ];
  };
}
