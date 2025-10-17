{ self, lib, config, pkgs, ... }:
{
  config = lib.mkIf config.hardware.keyboard.zsa.enable {
    environment.systemPackages = with pkgs; [
      wally-cli
      # keymapp
    ];
  }
}
