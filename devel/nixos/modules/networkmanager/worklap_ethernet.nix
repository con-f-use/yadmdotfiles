# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles
{ wifi, ethernet }: # enp0s13f0u1u4 or enp0s13f0u2u4
{
  "cuda_ethernet" = {
    connection = {
      id = "cuda_ethernet";
      uuid = "e5c03641-9144-32df-8e88-c6d2e24618d3";
      type = "ethernet";
      autoconnect-priority = "-999";
      interface-name = "${ethernet}";
    };
    ethernet = { };
    ipv4 = {
      address1 = "10.17.33.167/24,10.17.33.1";
      method = "manual";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
    proxy = { };
  };
}
