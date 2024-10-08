{ config, lib, pkgs, ... }:
{
    environment.systemPackages =
      map (x: x.terminfo) (
        with pkgs.pkgsBuildBuild;
        [
          alacritty
          foot
          kitty
          mtm
          rio
          rxvt-unicode-unwrapped
          rxvt-unicode-unwrapped-emoji
          st
          termite
          tmux
          wezterm
          yaft
        ]
    );

    environment.pathsToLink = [
      "/share/terminfo"
    ];

    environment.etc.terminfo = {
      source = "${config.system.path}/share/terminfo";
    };

    environment.profileRelativeSessionVariables = {
      TERMINFO_DIRS = [ "/share/terminfo" ];
    };

    environment.extraInit = ''

      # reset TERM with new TERMINFO available (if any)
      export TERM=$TERM
    '';

    security.sudo.extraConfig = lib.mkIf config.security.sudo.keepTerminfo ''

      # Keep terminfo database for root and %wheel.
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults:root,%wheel env_keep+=TERMINFO
    '';

}

