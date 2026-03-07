import { homedir } from "os";
import path from "path";

export const SYSTEMS = {
  macOS: "MacOS",
  linuxDesktop: "Linux - Desktop",
  linuxServer: "Linux - Server",
  rpi: "Raspberry Pi",
  cachyos: "CachyOS"
};

export const PATHS = [
  // Espanso
  {
    src: "./espanso/match/base.yml",
    dest: "~/.config/espanso/match/base.yml",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.cachyos],
  },
  {
    src: "./espanso/config/default.yml",
    dest: "~/.config/espanso/config/default.yml",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.cachyos],
  },
  // Ghostty
  {
    src: "./ghostty/config",
    dest: "~/.config/ghostty/config",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.cachyos],
  },
  {
    src: "./ghostty/config-linux",
    dest: "~/.config/ghostty/config-linux",
    systems: [SYSTEMS.linuxDesktop, SYSTEMS.cachyos],
  },
  {
    src: "./ghostty/config-macos",
    dest: "~/.config/ghostty/config-macos",
    systems: [SYSTEMS.macOS],
  },
  {
    src: "./ghostty/themes/skogen",
    dest: "~/.config/ghostty/themes/skogen",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.cachyos],
  },
  // Git
  {
    src: "./git/gitconfig",
    dest: "~/.gitconfig",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi, SYSTEMS.cachyos],
  },
  {
    src: "./git/git_commit_template.txt",
    dest: "~/.config/git/git_commit_template.txt",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/git_commit_template/main/git_commit_template.txt",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi, SYSTEMS.cachyos],
  },
  // Keymapper
  {
    src: "./keymapper/keymapper.conf",
    dest: "~/.config/keymapper.conf",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.cachyos],
  },
  // Niri
  {
    src: "./niri/config.kdl",
    dest: "~/.config/niri/config.kdl",
    systems: [SYSTEMS.cachyos],
  },
  {
    src: "./niri/cfg/animation.kdl",
    dest: "~/.config/niri/cfg/animation.kdl",
    systems: [SYSTEMS.cachyos],
  },
  {
    src: "./niri/cfg/keybinds.kdl",
    dest: "~/.config/niri/cfg/keybinds.kdl",
    systems: [SYSTEMS.cachyos],
  },
  // Ohmyzsh
  {
    src: "./ohmyzsh/themes/skogen.zsh-theme",
    dest: "~/.oh-my-zsh/themes/skogen.zsh-theme",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/skogen-theme/main/themes/skogen.zsh-theme",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi, SYSTEMS.cachyos],
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
  // ZSH
  {
    src: "./zsh/.zshrc",
    dest: "~/.zshrc",
    systems: [SYSTEMS.macOS, SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi, SYSTEMS.cachyos],
  },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
