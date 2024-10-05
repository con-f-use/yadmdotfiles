# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }:
{
  "Asgard" = {
    connection = {
      id = "Asgard";
      uuid = "3be6600d-5441-4765-9f21-79e6d017f18c";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      mode = "infrastructure";
      ssid = "Asgard";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "\${Asgard_secret}";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "stable-privacy";
      method = "auto";
    };
    proxy = { };
  };
}
