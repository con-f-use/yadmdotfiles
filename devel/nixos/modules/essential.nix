{ config, lib, pkgs, ... }:
{
options = with lib; {
  unfrees = mkOption { description = "List of unfree packages allowed"; type = types.listOf types.str; default = []; };
  roles.essentials = {
    enable = mkEnableOption "Things I can't linux without";  # Linux is a verb now!
    main_user = mkOption { description = "User name of the main user"; type = types.str; default = false; };
  };
};
config = lib.mkIf config.roles.essentials.enable {

  environment.homeBinInPath = true;

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME    = "\${HOME}/.local/bin";
    XDG_DATA_HOME   = "\${HOME}/.local/share";
    XDG_STATE_HOME  = "\${HOME}/.local/state";

    PATH = [ "\${XDG_BIN_HOME}" ];
  };

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

  environment.enableAllTerminfo = true;

  documentation.nixos.enable = false;  # When multiple output, don't install docs
  #system.autoUpgrade.enable = true;
  #system.autoUpgrade.allowReboot = true;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "${config.roles.essentials.main_user}" ];
        commands = [
          { command = "${pkgs.systemd}/bin/shutdown"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    # Essential
    htop gnupg age screen tree file binutils-unwrapped execline
    wget curl w3m
  ];

}; }

