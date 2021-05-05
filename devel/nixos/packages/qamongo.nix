
{ stdenv, fetchurl, zlib, glib, xorg, dbus, fontconfig, libGL,
  freetype, xkeyboard_config, makeDesktopItem, makeWrapper, qtdpi ? "120" }:

stdenv.mkDerivation rec {
  pname = "qamongo";
  version = "1.2.1";
  rev = "3e50a65";

  src = fetchurl {
    url = "https://github.com/Studio3T/robomongo/releases/download/v${version}/robo3t-${version}-linux-x86_64-${rev}.tar.gz";
    sha256 = "1sqdppqmikggiw7m4qw1g8yhp3ijjbazwgrcb020x7s839f1phra";
  };

  icon = fetchurl {
    url = "https://github.com/Studio3T/robomongo/raw/${version}/trash/install/linux/robomongo.png";
    sha256 = "15li8536x600kkfkb3h6mw7y0f2ljkv951pc45dpiw036vldibv2";
  };

  desktopItem = makeDesktopItem {
    name = "qamongo";
    exec = "robo3t";
    icon = icon;
    comment = "Query GUI for mongodb";
    desktopName = "Robo3T";
    genericName = "MongoDB management tool";
    categories = "Development;IDE;";
  };

  nativeBuildInputs = [makeWrapper];

  ldLibraryPath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
    glib
    xorg.libXi
    xorg.libxcb
    xorg.libXrender
    xorg.libX11
    xorg.libSM
    xorg.libICE
    xorg.libXext
    dbus
    fontconfig
    freetype
    libGL
  ];

  installPhase = ''
    BASEDIR=$out/lib/robo3t
    mkdir -p $BASEDIR/bin
    cp bin/* $BASEDIR/bin
    mkdir -p $BASEDIR/lib
    cp -r lib/* $BASEDIR/lib
    mkdir -p $out/share/applications
    cp $desktopItem/share/applications/* $out/share/applications
    mkdir -p $out/share/icons
    cp ${icon} $out/share/icons/robomongo.png
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $BASEDIR/bin/robo3t
    mkdir $out/bin
    makeWrapper $BASEDIR/bin/robo3t $out/bin/robo3t \
      --suffix LD_LIBRARY_PATH : ${ldLibraryPath} \
      --suffix QT_FONT_DPI : ${qtdpi} \
      --suffix QT_XKB_CONFIG_ROOT : ${xkeyboard_config}/share/X11/xkb
      # QT_SCALE_FACTOR
  '';

  meta = {
    homepage = "https://robomongo.org/";
    description = "Query GUI for mongodb";
    platforms = [ "x86_64-linux" ];
    license = stdenv.lib.licenses.gpl3;
    maintainers = [ stdenv.lib.maintainers.eperuffo ];
  };
}
