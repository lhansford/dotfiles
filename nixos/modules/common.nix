{ lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  users.users.luke = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "input"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      (lib.removeSuffix "\n" (builtins.readFile ../../keys/aphex.pub))
      (lib.removeSuffix "\n" (builtins.readFile ../../keys/jdilla.pub))
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;

  zramSwap.enable = true;

  powerManagement.enable = false;
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    "hybrid-sleep".enable = false;
  };

  time.timeZone = lib.mkDefault "Asia/Hong_Kong";

  system.stateVersion = "25.11";
}
