let
  main_user = "jan";
  # Generate passhash with: mkpasswd -m sha-512
  passhash = "$6$57NHYj5mJMl8......................5xMRvayTm8QQMT1";  
  ssh_pkeys = [
    "ssh-rsa <your key goes here>"
    "<second key....>"
  ];
in

{
  imports =
    [
      ./hardware-configuration.nix
      ./zfs-configuration.nix
    ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;
  hardware.opengl.driSupport32Bit = true;
  
  networking.hostName = "conix";
  networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  programs.ssh.extraConfig = ''
    Host gh
      HostName github.com
      User git
  '';

  security.sudo.enable = true;
  time.timeZone = "Europe/Vienna";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;  # Enable touchpad support.
    autorun = false;
    displayManager = {
      #defaultSession = "none+xmonad";
      startx.enable = true;
      gdm.enable = false;
      sddm.enable = false;
    };
    desktopManager = {
      gnome3.enable = false;
      plasma5.enable = false;
      xterm.enable = false;
    };
  };

  users.users."${main_user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "disk" "video" "docker" ];
    #openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = passhash;
  };

  environment.variables = { EDITOR = "nvim"; };
  environment.shellAliases = { ll="ls -al --color=auto"; ff="sudo vi /etc/nixos/configuration.nix"; ss="sudo nixos-rebuild switch"; };
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
    #open-vm-tools-headless
    htop gnupg screen tree rename file
    fasd fzf yadm pass ripgrep
    wget curl w3m inetutils dnsutils nmap openssl mkpasswd
    pipenv direnv 
    # steam xorg.libxcb
    # gcc gnumake xorg.libX11 xorg.libXinerama xorg.libXft pkgconfig # for building dwm
    picom nitrogen slock xorg.xrandr xorg.xinit xorg.xsetroot
    gitAndTools.git 
    gitAndTools.pre-commit gitAndTools.git-open gitAndTools.delta git-lfs
    nix-prefetch-scripts
    joypixels
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
        #vam.knownPlugins = pkgs.vimPlugins;
        #vam.pluginDictionaries = [ {
        #  names= [ "surround" "vim-nix" "tabular" "vim-commentary" "vim-obsession" "indentLine" "ale" ];
        #} ];
      };
    })

  ];

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "20.03";
}
