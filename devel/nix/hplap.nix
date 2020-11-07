{ config, pkgs, ...}:

let
  main_user = "jan";
  passhash = "$6$Xe3WNdmP$JqMUSRF3j6ytfCz7ceT1pI4Gw05FLy3n5UxkjSpQ7cilxcH/WoN8g2lOoVskJKoIDsadH9OiwHEaAUYZQXze7.";
in

{
  imports = [
    ./hardware-folio9470.nix
    ./zfs-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;
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
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  programs.ssh.extraConfig = ''
    Host gh
      HostName github.com
      User git
  '';

  security.sudo.enable = true;
  #security.wrappers = { slock.source = "${pkgs.slock.out}/bin/slock"; };
  time.timeZone = "Europe/Vienna";

  services.printing.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.clipmenu.enable = true;
  programs.slock.enable = true;  # screen lock needs privileges
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
    };
    desktopManager = {
      gnome3.enable = false;
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
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "disk" "video" "docker" ];
    #openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = passhash;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.variables = { EDITOR = "nvim"; };
  environment.shellAliases = { ll="ls -al --color=auto"; ff="sudo vi /etc/nixos/configuration.nix"; ss="echo 'Set a label: -p <label>'; sudo nixos-rebuild switch"; };
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
    htop gnupg screen tree rename file binutils-unwrapped
    fasd fzf yadm gopass ripgrep
    wget curl w3m inetutils dnsutils nmap openssl mkpasswd
    python3 poetry pipenv direnv
    st kitty xonsh
    firefox mpv youtube-dl
    tdesktop discord slack
    # steam xorg.libxcb
    # gcc gnumake xorg.libX11 xorg.libXinerama xorg.libXft pkgconfig # for building dwm
    picom nitrogen xorg.xrandr xorg.xinit xorg.xsetroot
    gitAndTools.git
    gitAndTools.pre-commit gitAndTools.git-open gitAndTools.delta git-lfs
    nix-prefetch-scripts
    pandoc typora xournalpp meld
    flameshot
    mpv ncmpcpp
    # ungoogled-chromium # in unstable!
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

  ];
  fonts.fonts = with pkgs; [
    cantarell-fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    fira-code-mono
    #mplus-outline-fonts
    dina-font
    proggyfonts
    joypixels
  ];

  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "20.09";
}

