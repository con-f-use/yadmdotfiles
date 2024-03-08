{ lib, ... }:
{
  system.stateVersion = "23.05"; # Do not edit this ever!
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  
  security.rtkit.enable = true;
  
  services.fwupd.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  systemd.tmpfiles.rules = [
    # See: https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
    "d!- /etc/secrets 0750 root root"  # 4:read 2:write 1:execute
    "Z- /etc/secrets 0750 root root"
  ];
}
