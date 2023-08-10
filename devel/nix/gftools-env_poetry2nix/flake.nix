{
  description = "bare-env, use with `nix develop`";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/9607b9149c9d81fdf3dc4f3bcc278da146ffbd77";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, poetry2nix }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    gftools = poetry2nix.legacyPackages.${system}.mkPoetryEnv {
      projectDir = null;
      pyproject = pkgs.writeText "pyproject.toml" ''
        [tool.poetry]
        name = "bare-env"
        version = "0.1.0"
        description = "Just a virtual environment managed with poetry"
        authors = ["confus"]

        [tool.poetry.dependencies]
        python = ">=3.9, <4.0"
        platformdirs = "*"


        [build-system]
        requires = ["poetry-core"]
        build-backend = "poetry.core.masonry.api"
      '';
      poetrylock = ./poetry.lock;
      preferWheels = true;
    };
  in
  {
    devShells.${system}.default = gftools.env;
  };
}
