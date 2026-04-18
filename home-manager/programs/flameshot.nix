_:

{
  # This is disabled as I couldn't get it to quite work on aphex. I think it was an issue with QT6, but not certain
  # Screenshotting would work, but selecting part of the screen wouldn't
  #
  # services = {
  #   flameshot = {
  #     enable = true;
  #     # Reference: https://github.com/flameshot-org/flameshot/blob/master/flameshot.example.ini
  #     settings = {
  #       General = {
  #         contrastOpacity = 188;
  #         savePath = "/home/luke/Downloads"; # TODO: This should be dropbox folder, but I haven't set that up on Jdilla yet. Also don't hardcode home dir.
  #         useGrimAdapter = true;
  #       };
  #     };
  #   };
  # };
   home = {
    file = {
      ".config/flameshot/flameshot.ini".source = ../../flameshot/flameshot.ini;
    };
   };
}