{
  description = "confus' NixOS configuration, modules and packages";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  # ToDo: Improve this by exposing the individual packages and modules
  outputs = { self, nixpkgs, nixunstable }: {
    nixosConfigurations = {
      connote = nixunstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./machines/hplap.nix ];
      };
      worklap = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./machines/worklap.nix ];
      };
      conix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./machines/workstationplayer.nix ];
      };
    };
  };
}
