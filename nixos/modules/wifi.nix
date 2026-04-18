{ ... }:

{
  networking.wireless = {
    enable = true;
    networks."Hansford-Chia" = {
      psk = "CHANGEME"; 
    };
  };
}
