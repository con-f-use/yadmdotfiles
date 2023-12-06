{ ... }: {
  conferencing = import ./conferencing.nix;
  cudawork = import ./cudawork;
  devel = import ./devel;
  electronics = import ./electronics.nix;
  essential = import ./essential.nix;
  gaming = import ./gaming.nix;
  nixnix = import ./nix;
  perswitch = import ./perswitch.nix;
  unfreepackages = import ./unfreepackages.nix;
  windowed = import ./windowed.nix;
  workstation = import ./workstation.nix;
  zfs = import ./zfs.nix;

  users = ../users/default.nix;
}
