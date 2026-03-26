# dotfiles

## Home Manager

Configuration is split into shared (`common.nix`) and per-host modules under `home-manager/hosts/`.

| Host    | File                        | Description                        |
| ------- | --------------------------- | ---------------------------------- |
| `aphex` | `hosts/aphex.nix`           | CachyOS desktop (Framework laptop) |
| `jdilla` | `hosts/jdilla.nix`         | Desktop with nvidia GPU             |

To apply a configuration, run from the `home-manager/` directory:

```sh
home-manager switch --flake ./home-manager/.#<host>
```

For example:

```sh
home-manager switch --flake ./home-manager/.#aphex
home-manager switch --flake ./home-manager/.#jdilla
```

To add a new host, create a file in `home-manager/hosts/` and register it in `home-manager/flake.nix`.

## TODO:

- Use nix for symlinks

- Flatpak update in zshrc
- Paru/pacman update in zsrhc
- Appimage updates?? Todoist specifically
- Sync noctalia and niri configs
- Sync nicotine and picard configs