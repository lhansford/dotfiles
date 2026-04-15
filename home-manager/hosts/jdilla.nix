{ ... }:

{
  imports = [
    ../environments/graphical.nix
    ../programs/ollama.nix
  ];

  # Nvidia support
  nixpkgs.config.nvidia.acceptLicense = true;
  targets.genericLinux.gpu.nvidia = {
    enable = true;

    # Keep in sync with CachyOS updates. See the home-manager docs.
    # Run the following to check the version:
    # nvidia-smi --query-gpu=driver_version --format=csv,noheader
    # Then provide a fake SHA ("sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=") to get Nix to give us the real one.
    version = "595.58.03";
    sha256 = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
  };
}
