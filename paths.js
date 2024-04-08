import { homedir } from "os";
import path from "path";

export const PATHS = [
  // Kitty
  { src: "./kitty/kitty.conf", dest: "~/.config/kitty/kitty.conf" },
  {
    src: "./kitty/themes/skogen.conf",
    dest: "~/.config/kitty/themes/skogen.conf",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.conf",
  },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
