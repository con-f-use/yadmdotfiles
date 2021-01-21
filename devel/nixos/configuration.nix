{ config, lib, pkgs, ...}:
{
  imports = [
    ./this.nix  # symlink to machine profile
    ./modules
    ./users
  ] ++ (lib.optional (builtins.pathExists ./cachix.nix) ./cachix.nix);


  roles.janEssential = { enable = true; main_user = config.users.users.jan.name; };
  roles.janDev.enable = true;
  roles.janX.enable = true;
  roles.janWorkstation.enable = true;
  roles.cudawork.enable = true;
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];

  # ToDo: This is a dirty hack so I can merge this with unfrees from other modles
  # no idea how to do it properly.
  myunfrees = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" ];  # ToDo: Move these to the modules that install them
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.myunfrees;

  system.stateVersion = "20.09";
}

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
