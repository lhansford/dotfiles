{ pkgs, lib, ... }:

{
  home.activation.reregisterEspanso = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.espanso-wayland}/bin/espanso service unregister 2>/dev/null || true
    $DRY_RUN_CMD ${pkgs.espanso-wayland}/bin/espanso service register || true
  '';

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    waylandSupport = true;

    configs = {
      default = {
        toggle_key = "OFF";
        search_trigger = "off";
        keyboard_layout = {
          layout = "us";
        };
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
          {
            trigger = ";llmtravel";
            replace = ''
               I want you to give me a list off 25 interesting things to do when I visit $|$ in $|$.

               Here are some of my interest to guide your choices, but don't let them be the sole criteria:

               - Good food, though not overly expensive/fancy. Particularly local cuisines.
               - Subcultures, underground music.
              	- Record stores.
              	- Modular/analog synthesis.
               - Coffee shops.
               - History.
               - Mechanical keyboards and similar tech/electronics stuff.
               - Cool shops for men's second hand clothing or outdoor clothing.

               Do not group into categories like "museums" or "record stores". I want discrete entries.

               Add a map link using Google maps.

               Format the list like `N. NAME_OF_PLACE: REASON_FOR_THE_RECOMMENDATION. MAP_LINK`.
            '';
          }
        ];
      };
    };
  };
}
