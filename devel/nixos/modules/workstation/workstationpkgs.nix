{ pkgs, ... }:
with pkgs; [
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
  #kitty-xterm-link
  oathToolkit
  qrencode
  conservetool
  usbutils
  lshw

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
