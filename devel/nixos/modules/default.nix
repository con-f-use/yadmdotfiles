{
  imports = [
    # Roles
    ./zfs.nix
    ./essential.nix
    ./devel.nix
    ./workstation.nix
    ./cudawork.nix
    ./graphical.nix
    ./gaming.nix

    # Modules
    ./perswitch.nix
  ];
}
