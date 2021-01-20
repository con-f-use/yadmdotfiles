{ config, pkgs, ...}:

let

  main_user = "jan";

  passhash = "$6$Xe3WNdmP$JqMUSRF3j6ytfCz7ceT1pI4Gw05FLy3n5UxkjSpQ7cilxcH/WoN8g2lOoVskJKoIDsadH9OiwHEaAUYZQXze7.";

  perswitch = import (fetchTarball { url = "https://github.com/con-f-use/PERSwitch/archive/80cc25dc29c7921d890185fef66ca89eabee6850.tar.gz"; sha256 = "14fxyh728mm3xsvrqaq4pchla7crbzni366hnyb0k8zxk9gsp31c"; }) {};

  cudapkgs = with pkgs; [
    devpi-client postgresql
    (python2.withPackages(ps: [
      ps.requests
      ps.pynvim
      ps.setuptools
      ps.six
      ps.virtualenv
      ps.libvirt
      ps.pycrypto
    ]))
  ];

in

{
  imports = [
    (if builtins.pathExists ./hardware-folio9470.nix then
      ./hardware-folio9470.nix 
    else
      ./hardware-workstationplayer.nix
    )
      ./zfs-configuration.nix
    ] ++ (if builtins.pathExists ./cachix.nix then [
      ./cachix.nix
    ] else []);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/var/tmp" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "defaults" "size=5%" ];
  };
  #swapDevices = [{device = "/swapfile"; size = 10000;}];  # doesn't seem to work
  hardware.opengl.driSupport32Bit = true;
  #virtualisation.vmware.guest.enable = true;

  networking.hostName = "conix";
  #networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  programs.ssh.extraConfig = ''
    Host gh
      HostName github.com
      User git
  '';

  security.sudo.enable = true;
  time.timeZone = "Europe/Vienna";

  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];  #pkgs.hplip
  programs.system-config-printer.enable = true;
  sound.enable = true;
  hardware.pulseaudio = { enable = true; package = pkgs.pulseaudioFull; };
  services.gvfs.enable = true;
  services.locate = { enable = true; interval = "hourly"; };
  #services.tor = { enable = true; client.enable = true; };
  #services.lorri.enable = true;
  services.earlyoom = { enable = true; freeMemThreshold = 5; };

  documentation.nixos.enable = false;

  virtualisation.docker = {
    enable = true;
    liveRestore = false;
    autoPrune.enable = true;
  };
  environment.etc."docker/daemon.json" = {
    enable = true;
    user = "docker";
    group = "docker";
    text = ''
      {
        "insecure-registries" : ["10.17.65.201:5000", "autotest-docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000"]
      }
    '';
  };

  # Enable the X11 windowing system.
  services.clipmenu.enable = true;
  programs.slock.enable = true;  # screen lock needs privileges
  services.xserver.exportConfiguration = true;
  #programs.xonsh.enable = true;
  programs.dconf.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;  # Enable touchpad support.
    autorun = true;
    displayManager = {
      #defaultSession = "none+dwm";
      defaultSession = "none+instantwm";
      #startx.enable = true;
      gdm.enable = false;
      sddm.enable = false;
      lightdm.greeters.gtk.theme.name = "Arc-Dark";
    };
    desktopManager = {
      gnome3.enable = false;
      gnome3.extraGSettingsOverrides = ''
        [org/gnome/nautilus/list-view]
        default-visible-columns=['name', 'size', 'date_modified_with_time']
        default-zoom-level='small'
        use-tree-view=false

        [org/gnome/nautilus/preferences]
        default-folder-viewer='list-view'
        executable-text-activation='ask'
        default-sort-order='mtime;'
      '';
      plasma5.enable = false;
      xterm.enable = false;
    };
    windowManager = {
      session = pkgs.lib.singleton {
        name = "instantwm";
        start = ''
          startinstantos &
          waitPID=$!
        '';
      };
      #dwm.enable = true;
    };
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = "*";
  users.users."${main_user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "plugdev" "adm" "disk" "video" "docker" ];
    #openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = passhash;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    # USBasp programmer
    ACTION=="add", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0660"
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.variables = { EDITOR = "nvim"; };
  environment.shellAliases = { 
    ll="ls -al --color=auto"; ff="sudo vi /etc/nixos/configuration.nix";
    ss="echo 'Set a label: -p <label>'; sudo nixos-rebuild switch";
    uu="sudo nix-channel --update; nix-channel --update";
    gg="sudo nix-collect-garbage -d; nix-collect-garbage";
  };
  environment.homeBinInPath = true;
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
  environment.systemPackages = with pkgs; [
    #open-vm-tools-headless  # e.g. for sharing dirs between guest and host
    htop gnupg screen tree rename file binutils-unwrapped cryptsetup
    fasd fzf yadm gopass ripgrep perswitch.perscom jq pinentry ncdu entr dos2unix
    wget curl w3m inetutils dnsutils nmap openssl sshpass mtr nload execline
    mkpasswd parallel zip trash-cli
    poetry pipenv direnv

    st kitty xonsh
    firefox youtube-dl
    franz signal-desktop zoom-us tdesktop discord slack
    thunderbird libreoffice
    gimp
    # steam xorg.libxcb
    xorg.xrandr xorg.xinit xorg.xsetroot xclip fribidi
    gitAndTools.git
    gitAndTools.pre-commit gitAndTools.git-open gitAndTools.delta git-lfs
    nix-prefetch-scripts nix-update nix-index nixpkgs-review nix-tree nix-top nixpkgs-fmt cachix morph
    pandoc typora xournalpp meld sxiv
    flameshot kazam
    deluge
    mpv ncmpcpp ffmpeg-full
    gnome3.file-roller font-manager  
    oathToolkit qrencode
    # ungoogled-chromium # in unstable!
    (python3.withPackages(ps: [
      ps.requests
      ps.beautifulsoup4
      ps.setuptools
      ps.virtualenv
      ps.pygls
      ps.python-language-server
      ps.pynvim
      ps.jedi
      ps.python-language-server
    ]))
    nodejs python-language-server
    (neovim.override {
      viAlias = true; vimAlias = true;
      configure = {
        customRC = ''
          set history=10000 | set undolevels=1000 | set laststatus=2 | set complete-=i | set list | set listchars=tab:»·,trail:·,nbsp:· | set autoindent | set backspace=indent,eol,start
          set smarttab | set tabstop=4 | set softtabstop=4 | set shiftwidth=4 | set expandtab | set shiftround | set number | set relativenumber | set nrformats-=octal | set incsearch
          set hlsearch | set autoread | set undofile | set undodir=~/.vim/dirs/undos | set nostartofline | set formatoptions+=j | set ruler | set scrolloff=3 | set sidescrolloff=8
          set display+=lastline | set wildmenu | set encoding=utf-8 | set tabpagemax=50 | set shell=/usr/bin/env\ bash | set visualbell | set noerrorbells | set ls=2
          colorscheme delek "desert "darkblue | let g:netrw_liststyle=3 | nnoremap Q q | nnoremap q <Nop> | command Wsudo :%!sudo tee > /dev/null %
          if has("autocmd")
            au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
          endif
          if filereadable(glob("~/.config/nvim/init.vim"))
            source $HOME/.config/nvim/init.vim
          endif
        '';
        vam.knownPlugins = pkgs.vimPlugins;
        vam.pluginDictionaries = [ {
          names= [ "surround" "vim-nix" "tabular" "vim-commentary" "vim-obsession" ];
        } ];
      };
    })
    papirus-icon-theme
    arc-theme
    gnome3.nautilus gsettings-desktop-schemas gnome3.dconf-editor
  ] ++ cudapkgs;
  fonts.fonts = with pkgs; [
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

  nixpkgs.config.allowUnfree = true;  # allowUnfreePredicate for individual packages
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      # builders-use-substitutes = true;
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    optimise.automatic = true;
    daemonNiceLevel = 19;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    #binaryCaches = [];
    #binaryCachePublicKeys = [];
    #distributedBuilds = true;
    #buildMachines = [ { hostname=; system="x86_64-linux"; maxJobs=100; supportedFeatures=["benchmark" "big-parallel"] } ];
  };

  system.stateVersion = "20.09";
}

