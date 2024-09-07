{ ... }:
{
  bash = import ./bash.nix;
  conferencing = import ./conferencing.nix;
  cudawork = import ./cudawork;
  devel = import ./devel;
  electronics = import ./electronics.nix;
  essential = import ./essential.nix;
  gaming = import ./gaming.nix;
  network = import ./networkmanager;
  nixnix = import ./nix;
  perswitch = import ./perswitch.nix;
  unfreepackages = import ./unfreepackages.nix;
  virt = import ./virt.nix;
  windowed = import ./windowed.nix;
  workstation = import ./workstation;
  zfs = import ./zfs.nix;

  users = ../users/default.nix;
}
