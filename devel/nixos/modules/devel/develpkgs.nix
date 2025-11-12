{ pkgs, ... }:
with pkgs;
[
  # Essential
  htop
  gnupg
  tree
  file
  binutils-unwrapped
  age
  age-plugin-yubikey
  yubico-piv-tool
  yubioath-flutter
  execline
  expect
  wget
  curl
  w3m
  magic-wormhole

  # Base
  lsof
  rename
  cryptsetup
  ncdu
  entr
  dos2unix

  # General
  fasd
  fzf
  ripgrep
  parallel
  pandoc
  figlet
  bat
  lnav
  libtool
  wakeonlan
  nvme-cli
  pciutils
  #texlive.combined.scheme-medium
  # (texlive.combine { inherit (texlive) scheme-medium xargs bigfoot moderncv lipsum footmisc multibib soul; })
  # ungoogled-chromium # in unstable!

  gparted
  pciutils
  transmission_4-gtk

  # Nix
  nix-prefetch-scripts
  nix-update
  nix-index
  nixpkgs-review
  nix-tree
  nix-visualize
  nix-du
  # nix-melt # broken
  manix
  nil
  nix-output-monitor
  nix-info
  nixpkgs-fmt
  cachix
  flakeroot

  # Python
  ruff
  (python3.withPackages (
    ps: with ps; [
      setuptools
      virtualenv
      #virtualenv-tools3
      requests
      beautifulsoup4
      pygls
      #pynvim
      jedi
      python-lsp-server
      matplotlib
      coloredlogs
      numpy
      dill
      #ps.pygrep
    ]
  ))
  black

  # Rust
  rust-analyzer
]
