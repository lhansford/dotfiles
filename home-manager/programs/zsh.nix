{ config, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;

    shellAliases = {
      code = "codium";
      gcfp = "git commit -a --amend --no-edit --no-verify && git push --force-with-lease";
      gho = "open \"https://github.com/$(git config --get remote.origin.url | cut -d \":\" -f 2  | cut -d \".\" -f 1)";
      l = "eza -la --group-directories-first";
      ls = "eza";
      trp = "op run -- todoist-random-project";
    };

    initContent = builtins.readFile ../../zsh/interactive-prompts.sh;

    oh-my-zsh = {
      enable = true;
      custom = "${config.home.homeDirectory}/.oh-my-zsh";
      plugins = [
        "aliases"
        "alias-finder"
        "docker-compose"
        "git"
        "z"
        "npm"
        "brew"
        "colorize"
        "dirhistory"
        "history"
      ];
      theme = "skogen";

      extraConfig = ''
        zstyle :omz:update frequency 7
        zstyle :omz:plugins:alias-finder autoload yes
      '';
    };
  };
}
