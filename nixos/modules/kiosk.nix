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
    # Force a dedicated profile to prevent flag-ignoring via process-reuse
    "--user-data-dir=/home/${cfg.user}/.config/chromium-kiosk"
    # Helps Cage treat the window correctly as a single-surface app
    "--app=${cfg.url}"
    "--start-maximized"
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
      program = "${pkgs.chromium}/bin/chromium ${chromiumFlags}";
    };
  };
}
