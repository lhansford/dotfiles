_:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityAgent = "~/.1password/agent.sock";
        extraOptions = {
          # We disable IdentitiesOnly for GitHub so it can "see" the keys inside the 1Password agent.
          IdentitiesOnly = "no";
        };
      };

      "codeberg.org" = {
        hostname = "codeberg.org";
        user = "git";
        identityAgent = "~/.1password/agent.sock";
        extraOptions = {
          # We disable IdentitiesOnly for GitHub so it can "see" the keys inside the 1Password agent.
          IdentitiesOnly = "no";
        };
      };

      "*" = {
        extraOptions = {
          IdentityAgent = "~/.1password/agent.sock";
          IdentitiesOnly = "yes";
        };
      };
    };
  };
}