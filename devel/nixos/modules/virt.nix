{ lib, config, pkgs, ... }:
{
  options.roles.virt.enable = lib.mkEnableOption "Enable kvm virtuatization";

  config = lib.mkIf config.roles.virt.enable {
    virtuatization.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;  # only emulates host arch, smaller download
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.unstable.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
  };
}
