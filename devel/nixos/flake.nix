{
  description = "confus' NixOS configuration, modules and packages";
  # Build with:
  # sudo nixos-rebuild switch --flake '/home/jan/devel/nixos/#<machine-name>'
  # --impure : needed if you want to use environment variables such as `sudo env NIXPKGS_ALLOW_BROKEN=1 nixos-rebuild --impure ...`
  # --no-build-hook : don't use subsitutors/builders
  # --builders "": same
  # --show-trace : show error traceback


  outputs = { self, nixpkgs, nixunstable, nixos-hardware, programsdb }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {

        conix = nixunstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; nixrepo = nixunstable; };
          modules = [
            #{ nixpkgs.overlays = [ inputs.emacs-overlay.overlay ]; }
            ./machines/workstationplayer.nix
          ];
        };

        framework = nixunstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; nixrepo = nixunstable; };
          modules = [
            nixos-hardware.nixosModules.framework
            ./machines/framework.nix
          ];
        };

        worklap = nixunstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; nixrepo = nixunstable; };
          modules = [
            nixos-hardware.nixosModules.dell-latitude-7490
            ./machines/worklap.nix
          ];
        };

        connote = nixunstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; nixrepo = nixunstable; };
          modules = [
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            ./machines/hplap.nix
          ];
        };

        raspi = nixunstable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; nixrepo = nixunstable; };
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-4
            ./machines/raspi.nix
          ];
        };

      };

      formatter."${system}" = nixunstable.legacyPackages."${system}".nixpkgs-fmt;
      #devShells
      #packages
      #apps
      #overlays
      #formatter
      #checks (nix flake check)
      #templates (nix flake init -t ./#<name>)
      #hydraJobs
    };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixunstable.url = "nixpkgs/nixos-unstable";
    # nixunstable.url = "github:NixOS/nixpkgs/d7705c01ef0a39c8ef532d1033bace8845a07d35";  # workes on workstation 21.01.2023
    # nixunstable.url = "9608ace7009ce5bc3aeb940095e01553e635cbc7";  # 13.9.22
    # nixunstable.url = "github:NixOS/nixpkgs/8203e061ec0556b4d4a972b18ba92509cb1ddd04";  # temporary because https://github.com/NixOS/nixpkgs/issues/172558
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    programsdb.url = "github:wamserma/flake-programs-sqlite";
  };

}
