_:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Luke Hansford";
        email = "mail@lukehansford.me";
      };

      gpg = {
        format = "ssh";
      };

      "gpg \"ssh\"" = {
        program = "/opt/1Password/op-ssh-sign";
      };

      commit = {
        gpgsign = true;
        template = "~/.config/git/git_commit_template.txt";
      };

      core.pager = "delta";
      core.editor = "codium --wait";
      color.ui = true;
      "color \"diff-highlight\"" = {
        oldNormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };
      "color \"diff\"" = {
        meta = "yellow";
        frag = "magenta bold";
        commit = "yellow bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };
      init.defaultBranch = "main";
      diff.noprefix = true;
      pull.rebase = false;

      delta.navigate = true;
      delta.theme = "zenburn";
      interactive.diffFilter = "delta --color-only";
    };

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOq797MuXw3T+ssSgo9Q0f5t/2QMJjQi2CzhDpJBAj67";
      signByDefault = true;
      format = "ssh";
    };
  };
}
