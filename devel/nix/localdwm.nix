# Frist clone:
#    git clone https://git.suckless.org/dwm
# then copy this file to the clone location.
#
# Build with:
#    nix-build default.nix
# If that succeeds it will create symlink:
#    ./result
# That symlink is also an indirect grabage colletor root in:
#    /nix/var/nix/gcroots/auto/
# meaning the target of the result symlink will not be garbage as long at the
# result simlink exists or manually removed from the gcroots.
# It is "indirect" because it points to ./result outside of the nix store.


# ToDo: Make this a flake and a git repository.

{ pkgs ? import <nixpkgs> {} }:  # test on nixpkgs-revision: 227522.d4226e3a4b5

pkgs.dwm.overrideDerivation (old: {
  src = ./.;
})
