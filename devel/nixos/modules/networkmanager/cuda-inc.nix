# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }:
{
  "cuda-inc" = {
    connection = {
      id = "cuda-inc";
      uuid = "46b328a2-f3d5-4135-97de-38cb4f47a1d0";
      type = "wifi";
      interface-name = "${wifi}";
    };
    wifi = {
      hidden = "true";
      ssid = "cuda-inc";
    };
    wifi-security.key-mgmt = "wpa-eap";
    "802-1x" = {
      eap = "peap;";
      identity = "jbischko@barracuda.com";
      password = "\${cuda_inc_secret}";
      phase2-auth = "mschapv2";
    };
    ipv4.method = "auto";
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = { };
  };
}
