{
  description = "NixOS system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      nixos-generators,
      home-manager,
      ...
    }:
    let
      lotusModules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        home-manager.nixosModules.home-manager
        ./hosts/lotus.nix
      ];
    in
    {
      nixosConfigurations.lotus = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = lotusModules;
      };

      packages.x86_64-linux.sdcard = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = lotusModules;
      };
    };
}
