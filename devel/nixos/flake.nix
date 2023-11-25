{
  description = "confus' Nix(OS) Stuff";

  outputs = inputs:
    let
      args = import ./args inputs;
    in
    {
      overlays = import ./packages/overlays.nix args;
      nixosModules = import ./modules/default.nix args;
      nixosConfigurations = import ./machines/default.nix args;
      packages = args.forSystems (system:
        import ./packages/default.nix { pkgs = args.${system}; }
      );
      formatter = args.forSystems (system: args.${system}.nixpkgs-fmt);
    };

  inputs = {
    programsdb.url = "github:wamserma/flake-programs-sqlite";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixunstable.url = "nixpkgs/nixos-unstable";
  };
}
