{ lib, config, pkgs, ... }: {

  options.roles.virt.enable = lib.mkEnableOption "Enable kvm virtuatization";

  config = lib.mkIf config.roles.virt.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm; # only emulates host arch, smaller download
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          # ToDo: Broken in current pkgs
          # packages = [
          #   (pkgs.OVMF.override {
          #     secureBoot = true;
          #     tpmSupport = true;
          #   }).fd
          # ];
        };
      };
    };

    programs.virt-manager.enable = true;
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [ qemu_kvm ];
  };

}
