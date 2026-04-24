

{ ... }:

{
  programs.zsh = {
    shellAliases = {
      fibprod = "assume fishbrain-production --exec --";
      fibstaging = "assume fishbrain-staging --exec --";
      fibinfra = "assume fishbrain-infrastructure --exec --";
    };
  };
}
