import { homedir } from "os";
import path from "path";

export const SYSTEMS = {
  macOS: "MacOS",
  linuxDesktop: "Linux - Desktop",
  linuxServer: "Linux - Server",
  rpi: "Raspberry Pi",
};

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
    systems: [SYSTEMS.linuxDesktop],
  },
  // Espanso
  {
    src: "./espanso/match/base.yml",
    dest: "~/.config/espanso/match/base.yml",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  },
  {
    src: "./espanso/config/default.yml",
    dest: "~/.config/espanso/config/default.yml",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  },
  // Ghostty
  {
    src: "./ghostty/config",
    dest: "~/.config/ghostty/config",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  },
  {
    src: "./ghostty/config-linux",
    dest: "~/.config/ghostty/config-linux",
    systems: [SYSTEMS.linuxDesktop],
  },
  {
    src: "./ghostty/config-macos",
    dest: "~/.config/ghostty/config-macos",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./ghostty/themes/skogen",
    dest: "~/.config/ghostty/themes/skogen",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  },
  // Git
  {
    src: "./git/gitconfig",
    dest: "~/.gitconfig",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi],
  },
  {
    src: "./git/git_commit_template.txt",
    dest: "~/.config/git/git_commit_template.txt",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/git_commit_template/main/git_commit_template.txt",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi],
  },
  // Keymapper
  {
    src: "./keymapper/keymapper.conf",
    dest: "~/.config/keymapper.conf",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  },
  // // Kitty
  // {
  //   src: "./kitty/kitty.conf",
  //   dest: "~/.config/kitty/kitty.conf",
  //   systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  // },
  // {
  //   src: "./kitty/themes/skogen.conf",
  //   dest: "~/.config/kitty/themes/skogen.conf",
  //   externalSrc:
  //     "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.conf",
  //   systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop],
  // },
  // Ohmyzsh
  {
    src: "./ohmyzsh/themes/skogen.zsh-theme",
    dest: "~/.oh-my-zsh/themes/skogen.zsh-theme",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.zsh-theme",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi],
  },
  // Polybar
  {
    src: "./polybar/polybar.desktop",
    dest: "~/.config/autostart/polybar.desktop",
    systems: [SYSTEMS.linuxDesktop],
  },
  {
    src: "./polybar/config.ini",
    dest: "~/.config/polybar/config.ini",
    systems: [SYSTEMS.linuxDesktop],
  },
  // Rofi
  {
    src: "./rofi/config.rasi",
    dest: "~/.config/rofi/config.rasi",
    systems: [SYSTEMS.linuxDesktop],
  },
  {
    src: "./rofi/rofi-control-center.py",
    dest: "~/.config/rofi/rofi-control-center.py",
    systems: [SYSTEMS.linuxDesktop],
  },
  {
    src: "./rofi/rofi-todoist.js",
    dest: "~/.config/rofi/rofi-todoist.js",
    systems: [SYSTEMS.linuxDesktop],
  },
  {
    src: "./rofi/bg-transparent.png",
    dest: "~/.config/rofi/bg-transparent.png",
    systems: [SYSTEMS.linuxDesktop],
  },
  // SketchyBar
  {
    src: "./sketchybar/plugins/battery.sh",
    dest: "~/.config/sketchybar/plugins/battery.sh",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./sketchybar/plugins/clock.sh",
    dest: "~/.config/sketchybar/plugins/clock.sh",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./sketchybar/plugins/front_app.sh",
    dest: "~/.config/sketchybar/plugins/front_app.sh",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./sketchybar/plugins/space.sh",
    dest: "~/.config/sketchybar/plugins/space.sh",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./sketchybar/plugins/volume.sh",
    dest: "~/.config/sketchybar/plugins/volume.sh",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./sketchybar/sketchybarrc",
    dest: "~/.config/sketchybar/sketchybarrc",
    systems: [SYSTEMS.macOS],
  },
  // ZSH
  {
    src: "./zsh/.zshrc",
    dest: "~/.zshrc",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi],
  },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
