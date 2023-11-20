{ ... }: {
  conferencing = import ./conferencing.nix;
  cudawork = import ./cudawork.nix;
  devel = import ./devel.nix;
  electronics = import ./electronics.nix;
  essential = import ./essential.nix;
  gaming = import ./gaming.nix;
  perswitch = import ./perswitch.nix;
  windowed = import ./windowed.nix;
  workstation = import ./workstation.nix;
  zfs = import ./zfs.nix;

  users = ../users/default.nix;
}
