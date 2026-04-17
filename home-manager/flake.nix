{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nur,
      nix-vscode-extensions,
      claude-code,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nix-vscode-extensions.overlays.default
          claude-code.overlays.default
        ];
      };
      mkHome =
        hostModule:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            nur.modules.homeManager.default
            ./common.nix
            hostModule
          ];
        };
    in
    {
      homeConfigurations = {
        aphex = mkHome ./hosts/aphex.nix;
        jdilla = mkHome ./hosts/jdilla.nix;
      };
    };
}
