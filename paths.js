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
  { src: "./polybar/polybar.desktop", dest: "~/.config/autostart/polybar.desktop", system: SYSTEMS.linux },
  { src: "./polybar/config.ini", dest: "~/.config/polybar/config.ini", system: SYSTEMS.linux },
  // ZSH
  { src: "./zsh/.zshrc", dest: "~/.zshrc" },
].map((p) => ({
  ...p,
  src: path.resolve(p.src),
  dest: p.dest.replace("~", homedir()),
}));
