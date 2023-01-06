{
  description = "confus' NixOS configuration, modules and packages";
  # Build with:
  # sudo nixos-rebuild switch --flake '/home/jan/devel/nixos/#<machine-name>'
  # --impure : needed if you want to use environment variables such as `sudo env NIXPKGS_ALLOW_BROKEN=1 nixos-rebuild --impure ...`
  # --no-build-hook : don't use subsitutors/builders
  # --builders "": same
  # --show-trace : show error traceback

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixunstable.url = "nixpkgs/nixos-unstable"; 
    # nixunstable.url = "9608ace7009ce5bc3aeb940095e01553e635cbc7";  # 13.9.22
    # nixunstable.url = "github:NixOS/nixpkgs/7225ed3fb13dede4ddbad24e83509b0c8836c730";  # 30.9.22 has error
    # nixunstable.url = "github:NixOS/nixpkgs/f8cac2894cc7748e36577109ae19b9a5755c2d40";  # 30.9.22 has error
    # nixunstable.url = "github:NixOS/nixpkgs/141266be879bd1063e01085eec69ea1db37607d4";   # 29.9.22 has error
    # nixunstable.url = "github:NixOS/nixpkgs/e94b2f2a9cea6ce14ffa22567d708371180886d6";   # 29.9.22 has error
    # nixunstable.url = "github:NixOS/nixpkgs/d07c45feb55a838c5060f424f88aefbc88c25036";     # 29.9.22 has error
    # nixunstable.url = "github:NixOS/nixpkgs/c0b69f571968269f35561cc09c17c710d938389d";     # 29.9.22 has error
    # nixunstable.url = "github:NixOS/nixpkgs/8203e061ec0556b4d4a972b18ba92509cb1ddd04";  # temporary because https://github.com/NixOS/nixpkgs/issues/172558
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixunstable, nixos-hardware }@inputs: {
    nixosConfigurations = {

      conix = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          ./machines/workstationplayer.nix
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

      worklap = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; nixrepo=nixunstable; };
        modules = [
          nixos-hardware.nixosModules.dell-latitude-7490
          ./machines/worklap.nix
        ];
      };

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
