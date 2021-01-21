{ pkgs, ... }:
{
  perswitch = import (
    fetchTarball {
      url = "https://github.com/con-f-use/PERSwitch/archive/80cc25dc29c7921d890185fef66ca89eabee6850.tar.gz"; 
      sha256 = "14fxyh728mm3xsvrqaq4pchla7crbzni366hnyb0k8zxk9gsp31c"; 
    }
  ) { pkgs=pkgs; };
  barracudavpn = pkgs.callPackage ./barracudavpn.nix {};
}

