{ config, lib, pkgs, ... }:
let
  x="x";
in {
options = with lib; {
  unfrees = mkOption { description = "List of unfree packages allowed"; type = types.listOf types.str; default = []; };
  roles.essentials = {
    enable = mkEnableOption "Things I can't linux without";  # Linux is a verb now!
    main_user = mkOption { description = "User name of the main user"; type = types.str; default = false; };
  };
};
config = lib.mkIf config.roles.essentials.enable {

  environment.homeBinInPath = true;

  environment.shellAliases = { 
    ll="ls -al --color=auto"; ff="sudo vi /etc/nixos/configuration.nix";
    ss="echo 'Set a label: -p <label>'; sudo nixos-rebuild switch";
    uu="sudo nix-channel --update; nix-channel --update";
    gg="sudo nix-collect-garbage -d; nix-collect-garbage";
  };

  environment.etc."inputrc".text = ''
    "\e[Z": menu-complete
    "\e\e[C": forward-word
    "\e\e[D": backward-word
    "\e[A": history-search-backward
    "\e[B": history-search-forward
  '';

  environment.etc."gitconfig".text = ''
    [alias]
    ci = commit
    co = checkout
    st = status
    d = diff
    l = log
    [core]
    pager = delta
    theme = "Monokai Extended"
  '';

  documentation.nixos.enable = false;  # When multiple output, don't install docs

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults    insults
      Cmnd_Alias BOOTCMDS = /sbin/shutdown,/usr/sbin/pm-suspend,/sbin/reboot
      ${config.roles.essentials.main_user} ALL=(root)NOPASSWD:BOOTCMDS
      wheel ALL=(root)NOPASSWD:BOOTCMDS
    '';
  };

  environment.systemPackages = with pkgs; [
    # Essential
    htop gnupg age screen tree file binutils-unwrapped execline
    wget curl w3m
  ];

}; }

