{
  imports = [
    # Roles
    ./zfs.nix
    ./electronics.nix
    ./essential.nix
    ./devel.nix
    ./workstation.nix
    ./cudawork.nix
    ./windowed.nix
    ./gaming.nix

    # Modules
    ./perswitch.nix

    # Experiment
    ./authprin.nix
  ];
}
