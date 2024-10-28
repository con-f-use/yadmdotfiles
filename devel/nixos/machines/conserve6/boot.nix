{ config
, lib
, pkgs
, ...
}:
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
    # boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "usbnet"
      "usbhid"
      "sd_mod"
      "e1000e"
      "r8169"
      "r8152"
      "cdc_ncm"
    ];
    #boot.initrd.kernelModules = [ ];
    initrd.kernelModules = [
      "xhci_pci"
      "cdc_ncm"
      "usbnet"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "r8152"
      "dm-snapshot"
    ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    initrd.network = {
      # For initrd networking, you should add the module(s) required for your network card to
      #boot.initrd.availableKernelModules. lspci -v | grep -iA8 'network\|ethernet'
      enable = true;
      ssh.enable = true;
      ssh.port = 3022;
      ssh.authorizedKeys = config.users.users.jan.openssh.authorizedKeys.keys;
      ssh.hostKeys = with config.veil.secrets; [ host_rsa.target host_ed.target ];
    };

    # wait for interfaces and devices to be powered (takes a bit for some usb devs)
    initrd.preDeviceCommands = lib.mkOrder 400 "sleep 5";
    initrd.preLVMCommands = lib.mkOrder 400 "sleep 5";
  };

  veil.secrets.host_rsa = {
    target = "/etc/secrets/initrd/ssh_host_ed25519_key";
    script = "gopass show Infrastructure/conserve6_ed";
  };
  veil.secrets.host_ed = {
    target = "/etc/secrets/initrd/ssh_host_rsa_key";
    script = "gopass show Infrastructure/conserve6_rsa";
  };
}
