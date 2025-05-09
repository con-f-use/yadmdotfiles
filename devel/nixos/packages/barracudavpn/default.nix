{
  stdenv,
  lib,
  requireFile,
  binutils-unwrapped,
  iproute2,
  zstd,
  autoPatchelfHook,
  version ? "5.3.6",
}:

let

  shas = {
    # nix-hash --type sha256 --flat --base32 VPNClient_*_Linux.tar.gz
    "5.1.5rc1" = "0gdn8rw0r9d4vb0vwy9ylwmbqd6zdaafgjfhx7l3b3ngy1syz56n";
    "5.1.4" = "00qwq3ma5whfws9i2z205q48j8z9i3vgbvaqgx6rvcbip6ld14zy";
    "5.2.2" = "1bp47179rvs2ahv02f0hna210n886bg7bj8x68qclkk3xj39hici";
    "5.3.6" = "16anhxhjwyw5xdlazlj9pyy5b5zb8m9993ifr3rqnn7fjwi5pj5y";
  };

in

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "barracudavpn";
  vpnfile = requireFile {
    name = "VPNClient_${finalAttrs.version}_Linux.tar.gz";
    sha256 = shas."${finalAttrs.version}";
    url = finalAttrs.meta.homepage;
    message = ''
      # Invocation notes:
      # Does not work properly as script because "security"
      # Run in bash terminal EXACTLY as is:
      sudo barracudavpn -p; sleep 3; sudo chmod a+r /etc/resolv.conf;
      sudo barracudavpn --verbose --start \
         --login '<username>' --serverpw "\$(<pwmanager_get_pw>)" \
         --config '~/.config/yadmdotfiles/cuda/barracudavpn'
      # First line restores state (also useful after disconnect)
      # Then wait for the output and confirm MFA. After that copy the
      # output and:
      eval "\$(
        xclip -o -selection primary |
        sed -n 's/executing:/sudo ip/p'
      )"; sudo chmod a+r /etc/resolv.conf;

      # Download from: ${finalAttrs.meta.homepage}/#/search?page=1&search=Linux&type=6
      # Disclaimer: The Licences of that file may apply!
      nix-store --add-fixed sha256 VPNClient_${finalAttrs.version}_Linux.tar.gz
      # build:
        nix-build -E "with import <nixpkgs> {}; callPackage ./barracudavpn.nix {}"
      # or install:
        nix-env -i -E 'f: (with import <nixpkgs> {}; callPackage f {})' -f barracudavpn.nix
    '';
  };
  src = null;
  nativeBuildInputs = [
    binutils-unwrapped
    autoPatchelfHook
    zstd
  ];
  propagatedBuildInputs = [ iproute2 ];
  unpackPhase = ''
    tar xf "${finalAttrs.vpnfile}" &&
      ar -x *.deb &&
      tar xf data.tar.* ||
        echo "'${finalAttrs.vpnfile}' is not an archive type, using as executable..." 1>&2
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    sed -E "s@sudo barracudavpn@sudo $out/bin/barracudavpn@g" \
      "${if (builtins.compareVersions "${version}" "5.3.5") == -1 then ./bcvpn_pre_5_3_5.sh else ./bcvpn.sh}" \
      > "$out/bin/bcvpn"
    chmod +x usr/local/bin/barracudavpn "$out/bin/bcvpn"
    cp usr/local/bin/barracudavpn "$out/bin/barracudavpn" ||
      cp ${finalAttrs.vpnfile} "$out/bin/barracudavpn"
  '';
  meta = {
    description = "Barracuda VPN Client for Linux";
    homepage = "https://dlportal.barracudanetworks.com";
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.confus ];
  };
})
