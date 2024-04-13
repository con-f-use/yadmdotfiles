{
  description = "confus' Nix(OS) Stuff";

  outputs = inputs: let args = import ./args inputs; in {
    overlays = import ./packages/overlays.nix args;
    nixosModules = import ./modules args;
    nixosConfigurations = import ./machines args;
    packages = args.forPkgs ./packages;
    formatter = args.forSystems (system: args.${system}.nixpkgs-fmt);
  };

  inputs = {
    programsdb.url = "github:wamserma/flake-programs-sqlite";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixunstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    cnsrv.url = "github:NixOS/nixpkgs/b98a4e1746acceb92c509bc496ef3d0e5ad8d4aa";  # ToDo: remove this
  };
}

