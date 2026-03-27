{ ... }:

{
  imports = [
    ../environments/graphical.nix
  ];

  # Nvidia support
  nixpkgs.config.nvidia.acceptLicense = true;
  targets.genericLinux.gpu.nvidia = {
    enable = true;

    # Keep in sync with CachyOS updates. See the home-manager docs.
    version = "595.45.04";
    sha256 = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
  };
}
