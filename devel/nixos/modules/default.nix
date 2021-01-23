{
  imports = [
    # Roles
    ./zfs.nix
    ./essential.nix
    ./devel.nix
    ./workstation.nix
    ./cudawork.nix
    ./windowed.nix
    ./gaming.nix

    # Modules
    ./perswitch.nix
  ];
}
