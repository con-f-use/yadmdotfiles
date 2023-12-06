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
    nixunstable.url = "nixpkgs/nixos-unstable";
  };
}

# Try:
