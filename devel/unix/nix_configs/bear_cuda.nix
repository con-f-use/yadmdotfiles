{ config, pkgs, ... }:
let
  main_user = "jan";
  # Generate passhash with: mkpasswd -m sha-512
  passhash = "$6$.y6/VZzz1yb$mCDlBIZ3Ey2uZBg7usNApxSq3nvKeHIMrsxO/c/Hg8EA18Nt2i7ey7O3/O9GC2j8CHkQ9BptEF5zd/LZE26w51";
  ip = "10.17.70.7";
  gateway = "10.17.70.1";
  dns = "8.8.8.8";
  ssh_pkeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6lLuZxKu3u3/yTpcSlfa+NZZGDywrvqwX2IhSn36BNFMMShQF/MX1Kuy5txEHDfhOgj8omBWV9X03N8vlmy3Hh9T0uZe6earw3VOU37hcHEhh0YdV+boWdD4lCllRZ1o0HtsoFqVBg4gHAIsMjBN0/eC2qfN6T1/8/Hlvqspjx/ZgQF34PkEA7r7nFvUOAh3E72AYNiScsd1SXTq5hMhUsEs9g4EMO5MYWft7ybsysoBcnJcE+oEnsKtbsIdVUBXGWGqBz+Q7FbhPLsJECJ4nhuxh6SPfemvDZ2r94s3/mykl1X7OTj1bKCgtigCY/UFBk9KHDZ1XCKTaE4xXHg5oEo8glx2g+cj4OwqdpNt1A8QTiITi44KOeojFQAYK6r1RN0hArHHXAT1H7j/ha5x4C05B4Jb7JaMHGk5kEqqm3QxKh3K4nrshBa3BBhBI8Gozw3oe+bzX5EXUXVzJyOKO6xMqF+MATOd5lPVzDRgxbsERPVz4JXFgo89S/QPhTRfSGeN77h42ZK7mj3eUC8z/F/2d60jJHRR75m6aoFC39oX2WHgvlvAhRVLWYh17ZxEjVxTIRkcUKO+uPUnY3l6Qp1B3bRQ38w695JLt7c9k2xSOVCkJW8R+WGqnFzO/vcGNbU8k9HkBSv0exk0+aPHkkp820iu5+DVzRvh6jtmoww== confus@confusion-2016-07-30"

    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAibH0zQORgQN2S5ZiUQgpABJl1huhMEwp+OHF07JQquXIZI+1JhDAzzzoYGFvFet6e4rNzqWZUXTjFacb58Rk9GPVwM7foQmiY5lH/kHeI/p85QzKFiVOOgGThdrpoJusX7EAlydBDxvPG/Wlo1DsJF65VHxxa6Ogd4ACYQNKj7TkSxS2mZa5cu8kVhonnd6D2VxhcvxK+X/i6c6Td2IGGhMxjMPJQyX9VzkD/8FXiaGpU+Vsu+NLEwzbR+4JUps/6G3aMhOEZ3iZUZVb8XB1W7DIxluQlS70JDkIdzjJiEN+mVxcMmDJtFGBjiXf2GB3aDQr7w6yeHvqkpy27txvFYCKc5LTBQxouX3CdII0rlyASXOe8UcvAZBc8ddMvcKJfcQwPORf4WDvA2pYEvcxHy0Pu0tW2MZPrCAvqDZRhby/pc4tFYsPLtcUPQJGIBsvPQlySmC2bjiU5US7k2MYRLh3YlBAwuOAayqflAN8ART5fajgZQtHYdykHEuBqDsLXYEP1Qbi/WUQlKdxDqkV1OjJEDkGZQNJMEqE4uUSoz7rJHBpZC2VDEJHJU5vnMXNuH9cRyzqgDyk9Coy2wdfm6y9p89LdRm+7cWfbBssvwqi5Xd5gPYoOQJ0aSX8T00hq37v6kbeB7ElQu7aiSdy9ZsGYh9RfTRaEvnHC7l+6Rs= cuda"
  ];
in
{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

  networking.hostName = let
    split = builtins.split "\\." ip;
    num = builtins.elemAt split ((builtins.length split)-1);
  in
  "${main_user}-li${num}";
  time.timeZone = "Europe/Vienna";
  networking.useDHCP = false;  # depricated option, should be set to false
  #networking.interfaces.ens192.useDHCP = true;
  networking.interfaces.ens192.ipv4.addresses = [ {
    address = ip;
    prefixLength = 24;
  } ];
  networking.defaultGateway = gateway;
  networking.nameservers = [ dns ];
  #networking.hosts = { "10.17.6.4" = [ "qashare" ]; };
  #networking.firewall.allowedTCPPorts = [ ... ];
  #networking.firewall.allowedUDPPorts = [ ... ];
  #networking.firewall.enable = false;


  services.openssh = { enable = true; passwordAuthentication = true; permitRootLogin = "no"; };

  services.cron = {
    enable = true;
    # systemCronJobs = [ "@reboot ${main_user} /bin/sh script.sh" ];
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults    insults
      Cmnd_Alias BOOTCMDS = ${pkgs.systemd}/bin/shutdown,${pkgs.systemd}/bin/reboot
      ${main_user} ALL=(root)NOPASSWD:BOOTCMDS
      wheel ALL=(root)NOPASSWD:BOOTCMDS
    '';
  };

  users.users."${main_user}" = {
    isNormalUser = true;
    shell = pkgs.xonsh;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "disk" "video" "docker" ];
    openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = passhash;
  };

  environment.etc."inputrc".text = "\"\\e[Z\": menu-complete\n\"\\e\\e[C\": forward-word\n\"\\e\\e[D\": backward-word\n\"\\e[A\": history-search-backward\n\"\\e[B\": history-search-forward";
  environment.variables = { EDITOR = "nvim"; };
  environment.shellAliases = {
    ll="ls -al --color=auto"; cc="sudo nvim /etc/nixos/configuration.nix";
    ss="sudo nixos-rebuild switch";
  };
  environment.homeBinInPath = true;
  environment.systemPackages = with pkgs; [
    open-vm-tools-headless
    wget curl inetutils dnsutils nmap openssl mkpasswd
    htop gnupg screen tree rename
    fasd fzf yadm pass ripgrep
    pipenv direnv
    gitAndTools.git gitAndTools.pre-commit git-lfs
    nix-prefetch-scripts
    (neovim.override {
      viAlias = true; vimAlias = true; #})
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
          source $HOME/.config/nvim/init.vim
        '';
        vam.knownPlugins = pkgs.vimPlugins;
        vam.pluginDictionaries = [ {
          names= [ "surround" "vim-nix" "tabular" "vim-commentary" "vim-obsession" "indentLine" "ale" ];
        } ];
      };
    })
  ];

  nix.autoOptimiseStore = true;
  nix.gc = { automatic = true; options = "--delete-older-than 14d"; };
  system.stateVersion = "20.03"; # https://nixos.org/nixos/options.html
}
