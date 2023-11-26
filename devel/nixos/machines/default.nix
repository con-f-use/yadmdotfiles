{ self, nixunstable, nixos-hardware, ... }:
{
  conix = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./workstationplayer.nix
    ];
  };

  framework = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      nixos-hardware.nixosModules.framework-12th-gen-intel
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./framework-13in-12th.nix
    ];
  };

  worklap = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      nixos-hardware.nixosModules.common-cpu-intel
      nixos-hardware.nixosModules.common-pc-laptop
      nixos-hardware.nixosModules.common-pc-ssd
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./lat7440
    ];
  };

  # env NIX_SSHOPTS=-tt nixos-rebuild switch --builders "''" --flake '/home/jan/devel/nixos/#conserve' --target-host jan@192.168.1.18 --use-remote-sudo
  conserve = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      nixos-hardware.nixosModules.framework-11th-gen-intel
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./conserve6
    ];
  };

  maren = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      nixos-hardware.nixosModules.dell-latitude-7490
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./maren.nix
    ];
  };

  connote = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      nixos-hardware.nixosModules.common-cpu-intel
      nixos-hardware.nixosModules.common-pc-laptop
      nixos-hardware.nixosModules.common-pc-ssd
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./hplap.nix
    ];
  };

  raspi = nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules) ++ [
      nixos-hardware.nixosModules.raspberry-pi-4
      { nixpkgs.overlays = [ self.overlays.default ]; }
      ./raspi.nix
    ];
  };
}
