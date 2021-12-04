{ pkgs, ... }:
{
  perswitch = import (
    fetchTarball {
      url = "https://github.com/con-f-use/PERSwitch/archive/4ddf0c5f12d7ff7259672de0c7278c76ddb229a9.tar.gz"; 
      sha256 = "18km0cwjkcx7067c861s10lpb94qb3n889iy03alavqa3p0p9xgx";
    }
  ) { pkgs=pkgs; };
  barracudavpn = pkgs.callPackage ./barracudavpn.nix {};
  qamongo = pkgs.callPackage ./qamongo.nix {};
}

