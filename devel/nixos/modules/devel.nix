{ self, config, lib, pkgs, inputs, ... }:
{
  options.roles.dev = {
    enable = lib.mkEnableOption "Development tools I use often";
  };

  config = lib.mkIf config.roles.dev.enable {

    # boot.tmp.useTmpfs = true;  # set false if large nix builds fail
    # boot.tmp.tmpfsSize = 80;   # percent of ram
    boot.tmp.cleanOnBoot = true;

    fileSystems."/var/tmp" = {
      fsType = "tmpfs";
      device = "tmpfs";
      options = [ "defaults" "size=5%" ];
    };

    boot.supportedFilesystems = [ "ntfs" ];

    programs.ssh.extraConfig = ''
      Host github hub gh
        HostName github.com
        User git
    '';

    programs.neovim = {
      withNodeJs = true;
      configure.packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ vim-nix vim-commentary vim-surround vim-ReplaceWithRegister nvim-treesitter.withAllGrammars ];
      };
    };

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      alsa-lib
      # at-spi2-atk at-spi2-core atk cups
      cairo
      curl
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      libdrm
      libnotify
      libpulseaudio
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      pipewire
      systemd
      icu
      openssl
      xorg.libxcb
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxkbfile
      xorg.libxshmfence
    ];

    services.kubo = {
      enable = true;
      autoMount = true;
      settings.Datastore.StorageMax = "100GB";
    };

    networking.firewall.allowedTCPPorts = [ 8000 8080 8081 8443 ];

    # Nix Package Manager
    nix = {
      optimise.automatic = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true; # newer
        # keep-* options:
        # - https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=keep-outputs#description
        # - https://github.com/NixOS/nix/issues/2208
        keep-outputs = true;
        keep-derivations = true;
        sandbox = true; # newer
        allowed-users = [ "@wheel" ];
        trusted-users = [ "@wheel" ];
        cores = 3;
        use-xdg-base-directories = true;
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      channel.enable = false;
      registry.nixpkgs.flake = self.inputs.nixunstable;
      nixPath = [ "nixpkgs=/etc/nixpkgs" ];
      #binaryCaches = [];
      #binaryCachePublicKeys = [];
      #distributedBuilds = true;
      #buildMachines = [ { hostname=; system="x86_64-linux"; maxJobs=100; supportedFeatures=["benchmark" "big-parallel"] } ];
    };
    programs.command-not-found.dbPath = "/etc/programs.sqlite";
    environment.etc = {
      "programs.sqlite".source = self.inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
      nixpkgs.source = pkgs.path;
      "source-${self.shortRev or self.dirtyShortRev or self.lastModified or "unknown"}".source = self; # system.copySystemConfiguration = true # for non-flake
    };

    environment = {
      variables = { EDITOR = "nvim"; };
    };

    #services.tor = { enable = true; client.enable = true; };

    programs.direnv.enable = true;
    environment.systemPackages = with pkgs; [
      # Essential
      htop
      gnupg
      screen
      tree
      file
      binutils-unwrapped
      age
      execline
      expect
      wget
      curl
      w3m
      magic-wormhole

      # Base
      rename
      cryptsetup
      ncdu
      entr
      dos2unix

      # General
      fasd
      fzf
      ripgrep
      parallel
      pandoc
      figlet
      bat
      lnav
      libtool
      #texlive.combined.scheme-medium
      # (texlive.combine { inherit (texlive) scheme-medium xargs bigfoot moderncv lipsum footmisc multibib soul; })
      # ungoogled-chromium # in unstable!

      gparted

      # Nix
      nix-prefetch-scripts
      nix-update
      nix-index
      nixpkgs-review
      nix-tree
      manix
      nix-index
      nix-top
      nil
      nix-output-monitor
      nix-info
      nixpkgs-fmt
      cachix
      morph

      # Python
      (python3.withPackages (ps: with ps; [
        setuptools
        virtualenv
        #virtualenv-tools3
        requests
        beautifulsoup4
        pygls
        #pynvim
        jedi
        # python-language-server
        matplotlib
        coloredlogs
        numpy
        dill
        #ps.pygrep
      ]))
      black

      # Rust
      rust-analyzer
    ] ++ (lib.optionals (config.services.xserver.enable) [ pkgs.meld pkgs.xournalpp ]);
  };

}

