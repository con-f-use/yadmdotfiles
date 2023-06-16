{
  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages."${system}";
  in {
    packages."${system}".test = pkgs.stdenv.mkDerivation {
      src = builtins.fetchGit {
        url="git@github.com:con-f-use/repo.git";
        rev="ba970eb37abf5a59ae668de5ac1e7bd25f929a17";
      };
      name = "testder";
      installPhase = ''cp -r ./ "$out"'';
    };
  };
}
