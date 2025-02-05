import { homedir } from "os";
import path from "path";

export const SYSTEMS = { macOS: "MacOS", linux: "Linux", rpi: "Raspberry Pi" };

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
  // Ghostty
  {
    src: "./ghostty/config",
    dest: "~/.config/ghostty/config",
    systems: [SYSTEMS.macOS, SYSTEMS.linux],
  },
  {
    src: "./ghostty/themes/skogen",
    dest: "~/.config/ghostty/themes/skogen",
    systems: [SYSTEMS.macOS, SYSTEMS.linux],
  },
  // Git
  { src: "./git/gitconfig", dest: "~/.gitconfig", systems: [SYSTEMS.macOS, SYSTEMS.linux, SYSTEMS.rpi] },
  {
    src: "./git/git_commit_template.txt",
    dest: "~/.config/git/git_commit_template.txt",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/git_commit_template/main/git_commit_template.txt",
    systems: [SYSTEMS.macOS, SYSTEMS.linux, SYSTEMS.rpi],
  },
  // Keymapper
  { src: "./keymapper/keymapper.conf", dest: "./.config/keymapper.conf", systems: [SYSTEMS.macOS, SYSTEMS.linux], },
  // Kitty
  { src: "./kitty/kitty.conf", dest: "~/.config/kitty/kitty.conf", systems: [SYSTEMS.macOS, SYSTEMS.linux] },
  {
    src: "./kitty/themes/skogen.conf",
    dest: "~/.config/kitty/themes/skogen.conf",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.conf",
    systems: [SYSTEMS.macOS, SYSTEMS.linux]
  },
  // Ohmyzsh
  {
    src: "./ohmyzsh/themes/skogen.zsh-theme",
    dest: "~/.oh-my-zsh/themes/skogen.zsh-theme",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.zsh-theme",
    systems: [SYSTEMS.macOS, SYSTEMS.linux, SYSTEMS.rpi]
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
  // SketchyBar
  { src: "./sketchybar/plugins/battery.sh", dest: "~/.config/sketchybar/plugins/battery.sh", systems: [SYSTEMS.macOS] },
  { src: "./sketchybar/plugins/clock.sh", dest: "~/.config/sketchybar/plugins/clock.sh", systems: [SYSTEMS.macOS] },
  { src: "./sketchybar/plugins/front_app.sh", dest: "~/.config/sketchybar/plugins/front_app.sh", systems: [SYSTEMS.macOS] },
  { src: "./sketchybar/plugins/space.sh", dest: "~/.config/sketchybar/plugins/space.sh", systems: [SYSTEMS.macOS] },
  { src: "./sketchybar/plugins/volume.sh", dest: "~/.config/sketchybar/plugins/volume.sh", systems: [SYSTEMS.macOS] },
  { src: "./sketchybar/sketchybarrc", dest: "~/.config/sketchybar/sketchybarrc", systems: [SYSTEMS.macOS] },
  // ZSH
  { src: "./zsh/.zshrc", dest: "~/.zshrc", systems: [SYSTEMS.macOS, SYSTEMS.linux, SYSTEMS.rpi] },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
