{ ... }:

{
  # Keep in sync with CachyOS updates. See the home-manager docs.
  targets.genericLinux.gpu.nvidia = {
    enable = true;
    version = "595.45.04";
    sha256 = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
  };
}
