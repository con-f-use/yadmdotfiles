{
  description = "confus' NixOS configuration, modules and packages";
  # Build with:
  # sudo nixos-rebuild switch --flake '/home/jan/devel/nixos/#<machine-name>'
  # --no-build-hook : don't use subsitutors/builders
  # --builders "": same
  # --show-trace : show error traceback

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    # nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixunstable.url = "github:NixOS/nixpkgs/a62844b302507c7531ad68a86cb7aa54704c9cb4";
    # nixunstable.url = "github:NixOS/nixpkgs/89b1c95a552f5eb67e4147ae9669e039aa5c68ca"; # 1.10.21
    # nixunstable.url = "github:NixOS/nixpkgs/506a8d129f6f786a4a636a8dd88767e965b83900"; # 30.9.21
    # nixunstable.url = "github:NixOS/nixpkgs/f8913a9ed7d0e5536ffb9b6cdb47b4a9e5d77ed3"; # 29.9.21
    nixunstable.url = "github:NixOS/nixpkgs/357bad603f72216b3f17c9b576586edd9ad51e96"; # 29.9.21 working?
    # nixunstable.url = "github:NixOS/nixpkgs/8203e061ec0556b4d4a972b18ba92509cb1ddd04";  # temporary because https://github.com/NixOS/nixpkgs/issues/172558
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  # ToDo: Improve this by exposing the individual packages and modules
  outputs = { self, nixpkgs, nixunstable, nixos-hardware } @ inputs: {
    nixosConfigurations = {

      connote = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-ssd
          ./machines/hplap.nix
        ];
      };

      worklap = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          nixos-hardware.nixosModules.dell-latitude-7490
          ./machines/worklap.nix
        ];
      };

      framework = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          nixos-hardware.nixosModules.framework
          ./machines/framework.nix
        ];
      };

      fwmin = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          nixos-hardware.nixosModules.framework
          # nixos-hardware.nixosModules.framework-12th-gen-intel
          ./machines/fwmin.nix
        ];
      };

      conix = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          ./machines/workstationplayer.nix
        ];
      };

      raspi = nixunstable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./machines/raspi.nix
        ];
      };

    };
  };
}
