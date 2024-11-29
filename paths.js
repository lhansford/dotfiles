import { homedir } from "os";
import path from "path";

const SYSTEMS = { macOS: "macOS", linux: "linux", rpi: "rpi" };

export const PATHS = [
  // Amethyst
  {
    src: "./amethyst/amethyst.yml",
    dest: "~/.amethyst.yml",
    systems: [SYSTEMS.macOS],
  },
  // Autostart
  {
    src: "./autostart/polybar.desktop",
    dest: "~/.config/autostart/polybar.desktop",
    systems: [SYSTEMS.linux],
  },
  // Espanso
  {
    src: "./espanso/match/base.yml",
    dest: "~/.config/espanso/match/base.yml",
    systems: [SYSTEMS.macOS, SYSTEMS.linux],
  },
  {
    src: "./espanso/config/default.yml",
    dest: "~/.config/espanso/config/default.yml",
    systems: [SYSTEMS.macOS, SYSTEMS.linux],
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
  // Ohmyzsh
  {
    src: "./ohmyzsh/themes/skogen.zsh-theme",
    dest: "~/.oh-my-zsh/themes/skogen.zsh-theme",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.zsh-theme",
  },
  // Polybar
  {
    src: "./polybar/polybar.desktop",
    dest: "~/.config/autostart/polybar.desktop",
    systems: [SYSTEMS.linux],
  },
  {
    src: "./polybar/config.ini",
    dest: "~/.config/polybar/config.ini",
    systems: [SYSTEMS.linux],
  },
  // Rofi
  { src: "./rofi/config.rasi", dest: "~/.config/rofi/config.rasi", systems: [SYSTEMS.linux] },
  { src: "./rofi/rofi-control-center.py", dest: "~/.config/rofi/rofi-control-center.py", systems: [SYSTEMS.linux] },
  { src: "./rofi/rofi-todoist.js", dest: "~/.config/rofi/rofi-todoist.js", systems: [SYSTEMS.linux] },
  { src: "./rofi/bg-transparent.png", dest: "~/.config/rofi/bg-transparent.png", systems: [SYSTEMS.linux] },
  // ZSH
  { src: "./zsh/.zshrc", dest: "~/.zshrc" },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
