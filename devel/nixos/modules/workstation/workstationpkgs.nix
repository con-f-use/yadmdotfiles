{ pkgs, ... }:
with pkgs;
[
  # Workstation
  yadm
  gopass
  gopass-jsonapi
  pinentry
  pinentry-curses
  pinentry-gtk2
  mkpasswd
  zip
  trash-cli
  st
  kitty
  oathToolkit
  qrencode
  ripgrep
  conservetool
  usbutils
  lshw
  lua
  zoxide

  # Network
  inetutils
  dnsutils
  nmap
  mtr
  openssl
  sshpass
  nload

  # Multimedia
  ncmpcpp
  ffmpeg-full
  deluge
]
