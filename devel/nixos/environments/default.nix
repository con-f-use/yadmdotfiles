{ self, lib ? pkgs.lib, pkgs, ... }: {
  default = self.devShells.${pkgs.system}.deploy-env;
  deploy-env = import ./deploy-env.nix { inherit self lib pkgs; };
}
