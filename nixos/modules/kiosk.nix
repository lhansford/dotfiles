{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.kiosk;
  chromiumFlags = lib.concatStringsSep " " [
    "--kiosk"
    "--ozone-platform=wayland"
    "--no-first-run"
    "--enable-features=OverlayScrollbar,UseOzonePlatform"
    "--autoplay-policy=no-user-gesture-required"
  ];
in
{
  options.kiosk = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "luke";
      description = "User account that runs the kiosk session.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      example = "https://dashboard.example.com";
      description = "URL that the kiosk Chromium session loads on boot.";
    };
  };

  config = {
    services.cage = {
      enable = true;
      inherit (cfg) user;
      program = "${pkgs.chromium}/bin/chromium ${chromiumFlags} ${lib.escapeShellArg cfg.url}";
    };
  };
}
