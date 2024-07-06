{ config, lib, pkgs, ... }:
{
  options.roles.windowed = {
    enable = lib.mkEnableOption "My graphical system based on X and instantOS";
  };

  config = lib.mkIf config.roles.windowed.enable {

    sound.enable = true;

    hardware.pulseaudio = { enable = true; package = pkgs.pulseaudioFull; };

    services.gvfs.enable = true;

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    '';

    services.clipmenu.enable = true;

    programs.slock.enable = true; # screen lock needs privileges

    services.xserver.exportConfiguration = true;

    #programs.xonsh.enable = true;

    programs.dconf.enable = true;

    # fix java windows
    environment.variables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      GTK_THEME = "Arc-Dark";
    };

    programs.firefox = {
      enable = true;
      preferences = {
        "ui.systemUsesDarkTheme" = 1;
        "toolkit.telemetry.pioneer-new-studies-available" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "browser.urlbar.suggest.history" = false;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.search.hiddenOneOffs" = "Google,Bing,Amazon.com,eBay,Twitter,Wikipedia (en)";
        "browser.tabs.unloadOnLowMemory" = true;
      };
    };

    # defaultSession = "none+dwm";
    services.displayManager.defaultSession = "none+instantwm";
    services.xserver = {
      enable = true;
      videoDrivers = [ "modsetting" ]; # intel, nvidia
      xkb.layout = "us";
      xkb.variant = "intl";
      autorun = true;
      verbose = 7;
      displayManager = {
        #startx.enable = true;
        lightdm.enable = true;
        lightdm.greeters.gtk.theme.name = "Arc-Dark";
        xserverArgs = [ "-verbose" ];
      };
      # desktopManager = {
      #   gnome.enable = false;
      #   gnome.extraGSettingsOverrides = ''
      #     [org/gnome/nautilus/list-view]
      #     default-visible-columns=['name', 'size', 'date_modified_with_time']
      #     default-zoom-level='small'
      #     use-tree-view=false

      #     [org/gnome/nautilus/preferences]
      #     default-folder-viewer='list-view'
      #     executable-text-activation='ask'
      #     default-sort-order='mtime;'
      #   '';
      # };
      windowManager = {
        session = pkgs.lib.singleton {
          name = "instantwm";
          start = ''
            /home/jan/.nix-profile/bin/startinstantos &
            waitPID=$!
          '';
        };
        dwm.enable = true;
      };
    };
    programs.nm-applet.enable = true;

    # Becasue discord "looses" this damn setting all the time
    systemd = {
      timers.discord-skip-update = {
        wantedBy = [ "timers.target" ];
        partOf = [ "discord-skip-update.service" ];
        timerConfig.OnCalendar = "daily";
      };
      services.discord-skip-update = {
        serviceConfig.Type = "oneshot";
        path = [ pkgs.jq ];
        script = ''
          target='/home/jan/.config/discord/settings.json'
          text=$(jq '. + {"SKIP_HOST_UPDATE": true}' $target)
          echo "$text" > "$target" || true
        '';
      };
    };

    fonts.packages = with pkgs; [
      cantarell-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      joypixels
      (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
    ];

    nixpkgs.config.joypixels.acceptLicense = true;

    allowUnfreePackages = [ "discord" "rar" "joypixels" ];
    environment.systemPackages = with pkgs; [
      # X
      xorg.xrandr
      xorg.xinit
      xorg.xsetroot
      xorg.xkill
      xclip
      fribidi
      wmctrl
      xorg.xwininfo # wmctrl-1.07 xwininfo-1.1.4 
      xdotool
      file-roller
      font-manager
      libadwaita
      papirus-icon-theme
      arc-theme
      nautilus
      gsettings-desktop-schemas
      dconf-editor
      youtube-dl
      signal-desktop
      tdesktop
      discord
      thunderbird

      # Multimedia
      mpv
      sox  # audio manipulation
      yt-dlp
      sxiv
      flameshot
      kazam
      mcomix #zathura
      rar # needed by mcomix for cbr support
      v4l-utils

      # Office
      libreoffice
      gimp
      tessen
      rofi

      kitty

      zathura
    ];

  };
}

