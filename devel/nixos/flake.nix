{
  description = "confus' NixOS configuration, modules and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.utils.follows = "flake-utils";
    };
  };

  # ToDo: Improve this by exposing the individual packages and modules
  outputs = { self, nixpkgs, nixunstable, nixos-hardware, nix-ld }: {
    nixosConfigurations = {

      connote = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-ssd
          ./machines/hplap.nix
        ];
      };

      worklap = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.dell-latitude-7490
          nix-ld.nixosModules.nix-ld
          ./machines/worklap.nix
        ];
      };

      conix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nix-ld.nixosModules.nix-ld
          ./machines/workstationplayer.nix
        ];
      };

      raspi = nixunstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./machines/raspi.nix
        ];
      };

    };
  };
}
