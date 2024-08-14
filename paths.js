import { homedir } from "os";
import path from "path";

const SYSTEMS = { macOS: "macOS", linux: "linux" };

export const PATHS = [
  // Amethyst
  {
    src: "./amethyst/amethyst.yml",
    dest: "~/.amethyst.yml",
    system: SYSTEMS.macOS,
  },
  // Autostart
  {
    src: "./autostart/polybar.desktop",
    dest: "~/.config/autostart/polybar.desktop",
    system: SYSTEMS.linux,
  },
  {
    src: "./autostart/xmodmap.desktop",
    dest: "~/.config/autostart/xmodmap.desktop",
    system: SYSTEMS.linux,
  },
  // Espanso
  {
    src: "./espanso/match/base.yml",
    dest: "~/.config/espanso/match/base.yml",
  },
  {
    src: "./espanso/config/default.yml",
    dest: "~/.config/espanso/config/default.yml",
  },
  // Git
  { src: "./git/gitconfig", dest: "~/.gitconfig" },
  {
    src: "./git/git_commit_template.txt",
    dest: "~/.config/git/git_commit_template.txt",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/git_commit_template/main/git_commit_template.txt",
  },
  // Kitty
  { src: "./kitty/kitty.conf", dest: "~/.config/kitty/kitty.conf" },
  {
    src: "./kitty/themes/skogen.conf",
    dest: "~/.config/kitty/themes/skogen.conf",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.conf",
  },
  // Polybar
  {
    src: "./polybar/polybar.desktop",
    dest: "~/.config/autostart/polybar.desktop",
    system: SYSTEMS.linux,
  },
  {
    src: "./polybar/config.ini",
    dest: "~/.config/polybar/config.ini",
    system: SYSTEMS.linux,
  },
  // Rofi
  { src: "./rofi/config.rasi", dest: "~/.config/rofi/config.rasi", system: SYSTEMS.linux },
  { src: "./rofi/rofi-control-center.py", dest: "~/.config/rofi/rofi-control-center.py", system: SYSTEMS.linux },
  { src: "./rofi/rofi-todoist.js", dest: "~/.config/rofi/rofi-todoist.js", system: SYSTEMS.linux },
  { src: "./rofi/bg-transparent.png", dest: "~/.config/rofi/bg-transparent.png", system: SYSTEMS.linux },
  // ZSH
  { src: "./zsh/.zshrc", dest: "~/.zshrc" },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
