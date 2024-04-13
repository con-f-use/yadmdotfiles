{ self, nixunstable, cnsrv, nixos-hardware, ... }:
let
  mkSystem = modules: nixunstable.lib.nixosSystem {
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules)
      ++ [{ nixpkgs.overlays = [ self.overlays.default ]; }]
      ++ modules;
  };
in
{
  conix = mkSystem [ ./workstationplayer.nix ];

  framework = mkSystem [
    nixos-hardware.nixosModules.framework-12th-gen-intel
    ./framework-13in-12th.nix
  ];

  worklap = mkSystem [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd
    ./lat7440
  ];

  # env NIX_SSHOPTS=-tt nixos-rebuild switch --builders "''" --flake '/home/jan/devel/nixos/#conserve' --target-host jan@192.168.1.18 --use-remote-sudo
  # conserve = mkSystem [
  #   nixos-hardware.nixosModules.framework-11th-gen-intel
  #   ./conserve6
  # ];
  conserve = cnsrv.lib.nixosSystem {  # ToDo: remove this when cnsrv not needed
    specialArgs = { inherit self; };
    modules = (builtins.attrValues self.nixosModules)
      ++ [{ nixpkgs.overlays = [ self.overlays.default ]; }]
      ++ [ ./conserve6 ];
  };

  maren = mkSystem [
    nixos-hardware.nixosModules.dell-latitude-7490
    ./maren.nix
  ];

  connote = mkSystem [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-ssd
    ./hplap.nix
  ];

  raspi = mkSystem [
    nixos-hardware.nixosModules.raspberry-pi-4
    ./raspi.nix
  ];
}
