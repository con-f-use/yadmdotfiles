# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{
  wifi ? "",
  ethernet ? "",
}:
{
  "NETGEAR" = {
    connection = {
      id = "NETGEAR";
      uuid = "d1115faf-6fca-4cb5-a2c5-58e33bf6b63b";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      bssid = "7C:FF:4D:60:74:7B";
      mode = "infrastructure";
      ssid = "NETGEAR";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "\${NETGEAR_secret}";
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
