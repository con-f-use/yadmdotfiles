with import <nixpkgs> {};

mkShell {
  buildInputs = [ pkgs.curl pkgs.wally-cli ];

  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    glib
    gtk3
    stdenv.cc.cc
    libusb1
    webkitgtk
  ];

  NIX_LD = builtins.readFile "${stdenv.cc}/nix-support/dynamic-linker";

  shellHook = ''
    wally_location="$HOME/.local/share/wally/wally"
    echo "wally: $wally_location;"
    if [ ! -f wally ]; then
      curl --location \
        --create-dirs --create-file-mode 0744 --output "$wally_location" \
        'https://configure.ergodox-ez.com/wally/linux'
    fi 
    chmod +x "$wally_location"
    "$wally_location"
  '';
}
