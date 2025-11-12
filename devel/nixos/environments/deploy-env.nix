{ self, lib, pkgs, ... }:
pkgs.mkShell {
  packages = [
    self.packages.${pkgs.system}.veil
  ];
}
