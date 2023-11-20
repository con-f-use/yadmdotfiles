{
  outputs = { self, nixunstable, nixos-hardware, programsdb } @ flake-inputs:
  let
    system = "x86_64-linux";
    inputs = flake-inputs // {
      inherit system;
      unfreeunstable = import nixunstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    };
  in
  {
    packages.${system} = import ./packages/default.nix inputs;
    overlays = import ./packages/overlays.nix inputs;
    nixosModules = import ./modules/default.nix inputs;
    nixosConfigurations = import ./machines/default.nix inputs;
    formatter.${system} = inputs.unfreeunstable.nixpkgs-fmt;
  };

  inputs = {
    programsdb.url = "github:wamserma/flake-programs-sqlite";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixunstable.url = "nixpkgs/nixos-unstable";
  };
}
