# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }:
{
  "Aragorn" = {
    connection = {
      id = "Aragorn";
      uuid = "58671504-e4d8-4c68-8704-5eb2d6b6e256";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      mode = "infrastructure";
      ssid = "Aragorn";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "\${Aragorn_secret}";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = { };
  };
}
