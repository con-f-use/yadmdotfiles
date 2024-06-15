# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }: # wlp166s0 or wlp0s20f3
{
  "AsgarD" = {
    connection = {
      id = "AsgarD";
      uuid = "47129202-18a6-49b2-ad9d-92e1f4e40eea";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      mode = "infrastructure";
      ssid = "AsgarD";
    };
    wifi-security = {
      # auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "\${AsgarD_secret}";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = {
    };
  };
}
