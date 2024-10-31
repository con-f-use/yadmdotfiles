{ pkgs, ... }:
{
  barracudavpn = pkgs.callPackage ./barracudavpn { };
  conservetool = pkgs.callPackage ./conservetool { };
  qda-repos = pkgs.callPackage ./qda-repos { };
  flakeroot = pkgs.callPackage ./flakeroot { };
  veil = pkgs.callPackage ./veil { };
  perscom =
    let
      ref = "4ddf0c5f12d7ff7259672de0c7278c76ddb229a9";
      perswitch = builtins.fetchTarball {
        url = "https://github.com/con-f-use/PERSwitch/archive/${ref}.tar.gz";
        sha256 = "18km0cwjkcx7067c861s10lpb94qb3n889iy03alavqa3p0p9xgx";
      };
    in
    pkgs.callPackage "${perswitch}/clientsoftware/perscom.nix" { };
}
