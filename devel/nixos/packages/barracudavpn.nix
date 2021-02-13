{ stdenv, callPackage, buildFHSUserEnv, requireFile, iproute, binutils-unwrapped, autoPatchelfHook }:

let

  barracudavpn = stdenv.mkDerivation rec {
    version = "5.1.5rc1";
    pname = "barracudavpn";
    vpnfile = requireFile {
      name = "VPNClient_${version}_Linux.tar.gz";
      sha256 = "0gdn8rw0r9d4vb0vwy9ylwmbqd6zdaafgjfhx7l3b3ngy1syz56n";  # nix-hash --type sha256 --flat --base32 VPNClient_*_Linux.tar.gz
      # sha256 = "00qwq3ma5whfws9i2z205q48j8z9i3vgbvaqgx6rvcbip6ld14zy";  # nix-hash --type sha256 --flat --base32 VPNClient_*_Linux.tar.gz 
      url = meta.homepage;
      message = ''
        # Download from: ${meta.homepage}/#/search?page=1&search=Linux&type=6
        nix-store --add-fixed sha256 VPNClient_${version}_Linux.tar.gz
        # build:
          nix-build -E "with import <nixpkgs> {}; callPackage ./barracudavpn.nix {}"
        # or install:
          nix-env -i -E 'f: (with import <nixpkgs> {}; callPackage f {})' -f barracudavpn.nix
      '';
    };
    src = null;
    #src = vpnfile;
    nativeBuildInputs = [ binutils-unwrapped autoPatchelfHook ];
    unpackPhase = ''true'';
    #unpackPhase = ''
    #  tar xf "$src"
    #  ar -x *.deb
    #  tar xf data.tar.xz
    #'';
    installPhase = ''
      mkdir -p "$out/bin"
      mkdir -p $out/etc/barracudavpn/
      touch $out/etc/barracudavpn/barracudavpn.conf
      cp ${vpnfile} "$out/bin/barracudavpn"
      #cp usr/local/bin/barracudavpn "$out/bin"
    '';
    meta = {
      description = "Barracuda VPN Client for Linux";
      homepage = "https://dlportal.barracudanetworks.com";
      license = stdenv.lib.licenses.unfree;
      platforms = stdenv.lib.platforms.linux;
      maintainers = [ stdenv.lib.maintainers.confus ];
    };
  };

in buildFHSUserEnv {
  name = barracudavpn.pname;
  targetPkgs = pkgs': [ barracudavpn iproute ];
  runScript = "/bin/barracudavpn";
  meta = barracudavpn.meta;
}

