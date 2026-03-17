{ pkgs, ... }:
with pkgs;
[
  stdenv.cc.cc
  zlib
  fuse3
  alsa-lib
  # at-spi2-atk at-spi2-core atk cups
  cairo
  curl
  dbus
  expat
  fontconfig
  freetype
  gdk-pixbuf
  glib
  gtk3
  libGL
  libappindicator-gtk3
  libdrm
  libnotify
  # libpulseaudio
  libuuid
  libxkbcommon
  mesa
  nspr
  nss
  pango
  pipewire
  systemd
  icu
  openssl
  libxcb
  libx11
  libxscrnsaver
  libxcomposite
  libxcursor
  libxdamage
  libxext
  libxfixes
  libxi
  libxrandr
  libxrender
  libxtst
  libxkbfile
  libxshmfence
]
