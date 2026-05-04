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
      devShells = args.forPkgs ./environments;
      formatter = args.forSystems (system: args.${system}.nixfmt-tree);
    };

  inputs = {
    nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    programsdb.url = "github:wamserma/flake-programs-sqlite";
    programsdb.inputs.nixpkgs.follows = "nixunstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    mothershipper.url = "github:con-f-use/mothershipper";
    mothershipper.inputs.nixpkgs.follows = "nixunstable";
  };
}
