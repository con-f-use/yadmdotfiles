{ config, lib, pkgs, ...}:
{
  imports = [
    ./this.nix  # symlink to machine profile
    ./modules
    ./users
  ] ++ (lib.optional (builtins.pathExists ./cachix.nix) ./cachix.nix);


  roles = {
    essentials = { enable = true; main_user = config.users.users.jan.name; };
    dev.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    cudawork.enable = true;
  };
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];

  # ToDo: This is a dirty hack so I can merge this with unfrees from other modles
  # no idea how to do it properly.
  unfrees = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" ];  # ToDo: Move these to the modules that install them
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;

  system.stateVersion = "20.09";
}

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
