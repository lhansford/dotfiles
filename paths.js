import { homedir } from "os";
import path from "path";

export const SYSTEMS = {
  linuxDesktop: "Linux - Desktop",
  linuxServer: "Linux - Server",
  rpi: "Raspberry Pi",
  cachyos: "CachyOS"
};
const ALL_SYSTEMS = [SYSTEMS.linuxDesktop, SYSTEMS.linuxServer, SYSTEMS.rpi, SYSTEMS.cachyos];
const ALL_GRAPHIC_SYSTEMS = [SYSTEMS.linuxDesktop, SYSTEMS.cachyos];

export const PATHS = [
  // Espanso
  {
    src: "./espanso/match/base.yml",
    dest: "~/.config/espanso/match/base.yml",
    systems: ALL_GRAPHIC_SYSTEMS,
  },
  {
    src: "./espanso/config/default.yml",
    dest: "~/.config/espanso/config/default.yml",
    systems: ALL_GRAPHIC_SYSTEMS,
  },
  // Ghostty
  {
    src: "./ghostty/config",
    dest: "~/.config/ghostty/config",
    systems: ALL_GRAPHIC_SYSTEMS,
  },
  {
    src: "./ghostty/config-linux",
    dest: "~/.config/ghostty/config-linux",
    systems: ALL_GRAPHIC_SYSTEMS,
  },
  {
    src: "./ghostty/themes/skogen",
    dest: "~/.config/ghostty/themes/skogen",
    systems: ALL_GRAPHIC_SYSTEMS,
  },
  // Git
  {
    src: "./git/gitconfig",
    dest: "~/.gitconfig",
    systems: ALL_SYSTEMS,
  },
  {
    src: "./git/git_commit_template.txt",
    dest: "~/.config/git/git_commit_template.txt",
    externalSrc:
      "https://raw.githubusercontent.com/lhansford/git_commit_template/main/git_commit_template.txt",
    systems: ALL_SYSTEMS,
  },
  // Keymapper
  {
    src: "./keymapper/keymapper.conf",
    dest: "~/.config/keymapper.conf",
    systems: ALL_GRAPHIC_SYSTEMS,
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
    systems: ALL_SYSTEMS,
  },
  // ZSH
  {
    src: "./zsh/.zshrc",
    dest: "~/.zshrc",
    systems: ALL_SYSTEMS,
  },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
