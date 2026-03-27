_:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      extraOptions = {
        AddKeysToAgent = "yes";
        IdentitiesOnly = "yes";
      };
    };
  };
}
