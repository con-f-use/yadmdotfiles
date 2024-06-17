{ config, lib, ... }:
{
  options.roles.virt.enable = lib.mkEnableOption "enable libvirt virtualization";

  config = lib.mkIf options.roles.virt.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    programs.dconf.enable = true;
  };
}
