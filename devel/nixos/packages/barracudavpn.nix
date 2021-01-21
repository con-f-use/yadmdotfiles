{ stdenv, callPackage, buildFHSUserEnv, requireFile, iproute, binutils-unwrapped, autoPatchelfHook }:

let

  barracudavpn = stdenv.mkDerivation rec {
    version = "5.1.4";
    pname = "barracudavpn";
    src = requireFile {
      name = "VPNClient_${version}_Linux.tar.gz";
      sha256 = "00qwq3ma5whfws9i2z205q48j8z9i3vgbvaqgx6rvcbip6ld14zy";
      url = meta.homepage;
      message = ''
        Download from: https://dlportal.barracudanetworks.com/#/search?page=1&search=Linux&type=6
        nix-store --add-fixed sha256 VPNClient_5.1.4_Linux.tar.gz
        nix-hash --type sha256 --flat --base32 VPNClient_5.1.4_Linux.tar.gz
        nix-build -E "with import <nixpkgs> {}; callPackage ./barracudavpn.nix {}"
      '';
    };
    nativeBuildInputs = [ binutils-unwrapped autoPatchelfHook ];
    unpackPhase = ''
      tar xf "$src"
      ar -x *.deb
      tar xf data.tar.xz
    '';
    installPhase = ''
      mkdir -p "$out/bin"
      mkdir -p $out/etc/barracudavpn/
      touch $out/etc/barracudavpn/barracudavpn.conf
      cp usr/local/bin/barracudavpn "$out/bin"
    '';
    meta = {
      description = "Barracuda VPN Client for Linux";
      homepage = "https://dlportal.barracudanetworks.com";
      license = stdenv.lib.licenses.unfree;
      platforms = stdenv.lib.platforms.linux;
      #maintainers = [ stdenv.lib.maintainers.confus ];
    };
  };

in buildFHSUserEnv {
  name = barracudavpn.pname;
  targetPkgs = pkgs': [ barracudavpn iproute ];
  runScript = "/bin/barracudavpn";
  meta = barracudavpn.meta;
}

