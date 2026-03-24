{ config, pkgs, ... }:

let
  onePassPath = "~/.1password/agent.sock";
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  targets.genericLinux.enable = true;
  # This will need to keep in sync with CachyOS updates. See the home-manager docs.
  targets.genericLinux.gpu.nvidia = {
    enable = true;
    version = "595.45.04";
    sha256 = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
  };

  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "luke";
    homeDirectory = "/home/luke";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.

    packages = [
      # Dropbox client
      pkgs.maestral
      pkgs.maestral-gui

      pkgs.gum
      pkgs.diff-so-fancy
      pkgs.ghostty
      pkgs.mise

      pkgs.google-chrome
      pkgs.slack

      pkgs.todoist-electron
      pkgs.obsidian
      pkgs.fastmail-desktop
      pkgs.discord
      pkgs.plexamp

      # pkgs.espanso-wayland

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';

      ".config/git/git_commit_template.txt".source = ../git/git_commit_template.txt;
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/luke/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${onePassPath}
      '';
    };

    git = {
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
          program = "op-ssh-sign";
        };

        commit = {
          gpgsign = true;
          template = "~/.config/git/git_commit_template.txt";
        };

        core.pager = "diff-so-fancy | less --tabs=4 -RFX";
        core.editor = "code --wait";
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
      };

      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOq797MuXw3T+ssSgo9Q0f5t/2QMJjQi2CzhDpJBAj67";
        signByDefault = true;
        format = "ssh";
      };
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.extensions = with pkgs.vscode-extensions; [ ];
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "aliases"
          "alias-finder"
          "docker-compose"
          "git" # also requires `programs.git.enable = true;`
          "z"
          "npm"
          "brew"
          "colorize"
          "dirhistory"
          "history"
        ];
        theme = "robbyrussell";
      };
    };

    atuin = {
      enable = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";
      };
    };

    ghostty = {
      enable = true;
      enableZshIntegration = true;

      settings = {

        theme = "skogen";

        font-family = "Inconsolata Nerd Font Mono Regular";
        font-family-bold = "Inconsolata Nerd Font Mono Bold";
        background-opacity = 0.9;
        background-blur-radius = 16;

        adjust-cursor-thickness = 3;

        keybind = [
          "control+w=close_surface"
          "control+q=quit"
          "performable:ctrl+c=copy_to_clipboard"
          "ctrl+v=paste_from_clipboard"
          "ctrl+t=new_tab"
          "ctrl+down=new_split:down"
          "ctrl+right=new_split:right"
          "ctrl+1=goto_tab:1"
          "ctrl+2=goto_tab:2"
          "ctrl+3=goto_tab:3"
          "ctrl+4=goto_tab:4"
          "ctrl+5=goto_tab:5"
          "ctrl+6=goto_tab:6"
          "ctrl+7=goto_tab:7"
          "ctrl+8=goto_tab:8"
          "ctrl+9=goto_tab:9"
          "ctrl+0=goto_tab:10"

          # Added by Claude Code
          "shift+enter=text:\x1b\r"
        ];

        font-size = 10;

        shell-integration-features = "ssh-terminfo,ssh-env";
      };

      themes = {
        skogen = {
          palette = [
            # "0=#000000"
            "1=#E25E3E"
            "2=#7D9863"
            "3=#D0883E"
            "4=#176B87"
            "5=#B0578D"
            # "6=#f200fa"
            # "7=#bbbbbb"
            "8=#555555"
            "9=#DF7861"
            "10=#4E683E"
            "11=#FF8445"
            "12=#72D8FD"
            "13=#fd28ff"
            # "14=#f200fa"
            # "15=#ffffff"
          ];
          background = "2a2a26";
          foreground = "D0D0D2";
          cursor-color = "4E683E";
          selection-background = "FFF7D0";
          selection-foreground = "2a2a26";
        };
      };
    };
  };

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    waylandSupport = true;

    configs = {
      default = {
        toggle_key = "OFF";
        search_trigger = "off";
      };
    };

    matches = {
      default = {
        matches = [
          {
            trigger = ";em";
            replace = "mail@lukehansford.me";
          }
          {
            trigger = ";oem";
            replace = "l.s.hansford@gmail.com";
          }
          {
            trigger = ";wem";
            replace = "luke@fishbrain.com";
          }
          {
            trigger = ";evem";
            replace = "evelynchia98@gmail.com";
          }
          {
            trigger = ";lh";
            replace = "Luke Hansford";
          }
          {
            trigger = ";add";
            replace = "5F Greenmont Court, Discovery Bay Road, Discovery Bay, Lantau Island, Hong Kong";
          }
          {
            trigger = ";pn";
            replace = "198710053276";
          }
          {
            trigger = ";ph";
            replace = "+85262094782";
          }
          {
            trigger = ";evph";
            replace = "+85262332572";
          }
          {
            trigger = ";site";
            replace = "https://lukehansford.me";
          }
          {
            trigger = ";date";
            replace = "{{mydate}}";
            vars = [
              {
                name = "mydate";
                type = "date";
                params = {
                  format = "%Y-%m-%d";
                };
              }
            ];
          }
          {
            trigger = ";yest";
            replace = "{{mydate}}";
            vars = [
              {
                name = "mydate";
                type = "date";
                params = {
                  format = "%Y-%m-%d";
                  offset = -86400;
                };
              }
            ];
          }
          {
            trigger = ";comp";
            replace = ''
              type Props = {}

              export function ComponentName({}: Props) {
                return <></>;
              }
            '';
          }
          {
            trigger = ";exp";
            replace = ''
              ## Week $|$, 2022 -

              *Goal*:
              *Hypothesis*:
              *Outcome*: In progress
            '';
          }
          {
            trigger = ";refs";
            replace = ''
              ## References

              [^1]: [Title](url)
            '';
          }
          {
            trigger = ";mns";
            replace = ''
              # $|$ [{{mydate}}]

              ## Discussion items

              ## Notes

              ## Action points
            '';
            vars = [
              {
                name = "mydate";
                type = "date";
                params = {
                  format = "%Y-%m-%d";
                };
              }
            ];
          }
          {
            trigger = ";llmtext";
            replace = ''
              You are a proofreader for posts about to be published.

              1. Identify spelling mistakes and typos
              2. Identify grammar mistakes
              3. Watch out for repeated terms like "It was interesting that X, and it was interesting that Y"
              4. Spot any logical errors or factual mistakes
              5. Highlight weak arguments that could be strengthened
              6. Make sure there are no empty or placeholder links

              Here is the text:
            '';
          }
          {
            trigger = ";llmpr";
            replace = ''
              **Disclaimer**: This commit was mostly generated using Claude Code. I
              have reviewed all code changes myself, but would appreciate a review
              with consideration that some of code is generated.
            '';
          }
          {
            trigger = ";tff";
            replace = "terraform fmt -recursive";
          }
          {
            trigger = ";recruiter";
            replace = ''
              Hi $|$,

              Thanks for reaching out, but I'm not currently looking for a new position. Good luck finding the right person for the job.

              Regards,
              Luke
            '';
          }
          {
            trigger = ";fb";
            replace = "fishbrain";
          }
          {
            trigger = ";co2";
            replace = "CO<sub>2</sub>";
          }
          {
            trigger = ";deg";
            replace = "°C";
          }
        ];
      };
    };
  };
}
