{
  description = "confus' Nix(OS) Stuff";

  outputs =
    inputs:
    let
      args = import ./args inputs;
    in
    {
      overlays = import ./packages/overlays.nix args;
      nixosModules = import ./modules args;
      nixosConfigurations = import ./machines args;
      packages = args.forPkgs ./packages;
      formatter = args.forSystems (system: args.${system}.nixfmt-tree);
    };

  inputs = {
    programsdb.url = "github:wamserma/flake-programs-sqlite";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    mothershipper.url = "github:con-f-use/mothershipper";
    mothershipper.inputs.nixpkgs.follows = "nixunstable";
  };
}
