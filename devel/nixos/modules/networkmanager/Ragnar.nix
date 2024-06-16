# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }: {
  "Ragnar" = {
    connection = {
      id = "Ragnar";
      uuid = "6c9cf687-6736-461e-bd9a-7d48d71b3df5";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      mode = "infrastructure";
      ssid = "Ragnar";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-psk";
      psk = "\${Ragnar_secret}";
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
