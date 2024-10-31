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
      formatter = args.forSystems (system: args.${system}.nixfmt-rfc-style);
    };

  inputs = {
    programsdb.url = "github:wamserma/flake-programs-sqlite";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    mcomnix.url = "github:NixOS/nixpkgs/051f920625ab5aabe37c920346e3e69d7d34400e"; # ToDo: remove once it works again on nixunstable
  };
}
