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
  xorg.libxcb
  xorg.libX11
  xorg.libXScrnSaver
  xorg.libXcomposite
  xorg.libXcursor
  xorg.libXdamage
  xorg.libXext
  xorg.libXfixes
  xorg.libXi
  xorg.libXrandr
  xorg.libXrender
  xorg.libXtst
  xorg.libxkbfile
  xorg.libxshmfence
]
