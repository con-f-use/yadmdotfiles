{ pkgs, ... }:
with pkgs; [
  # Essential
  htop
  gnupg
  screen
  tree
  file
  binutils-unwrapped
  age
  execline
  expect
  wget
  curl
  w3m
  magic-wormhole

  # Base
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
  #texlive.combined.scheme-medium
  # (texlive.combine { inherit (texlive) scheme-medium xargs bigfoot moderncv lipsum footmisc multibib soul; })
  # ungoogled-chromium # in unstable!

  gparted

  # Nix
  nix-prefetch-scripts
  nix-update
  nix-index
  nixpkgs-review
  nix-tree
  manix
  nix-top
  nil
  nix-output-monitor
  nix-info
  nixpkgs-fmt
  cachix
  morph

  # Python
  (python3.withPackages (ps: with ps; [
    setuptools
    virtualenv
    #virtualenv-tools3
    requests
    beautifulsoup4
    pygls
    #pynvim
    jedi
    # python-language-server
    matplotlib
    coloredlogs
    numpy
    dill
    #ps.pygrep
  ]))
  black

  # Rust
  rust-analyzer
]
