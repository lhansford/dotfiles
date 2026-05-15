{ lib, ... }:

{
  imports = [
    ../environments/graphical.nix
  ];

  # Nvidia support
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  targets.genericLinux.gpu.nvidia = {
    enable = true;

    # Keep in sync with CachyOS updates. See the home-manager docs.
    # Run the following to check the version:
    # nvidia-smi --query-gpu=driver_version --format=csv,noheader
    # Then provide a fake SHA ("sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=") to get Nix to give us the real one.
    version = "595.71.05";
    sha256 = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";
  };

  programs.git.signing.key = lib.removeSuffix "\n" (builtins.readFile ../../keys/jdilla.pub);
}
