# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }:
{
  "Basti 27" = {
    connection = {
      id = "Basti 27";
      uuid = "e14242c6-bded-4848-a2ab-8b8b334098d6";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      mode = "infrastructure";
      ssid = "Basti 27";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "\${Basti27_secret}";
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
