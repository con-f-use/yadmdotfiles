{ config, lib, pkgs, inputs, nixrepo, ... }:
let
  base-neovim = (pkgs.neovim.override {
      viAlias = true; vimAlias = true; withNodeJs = true;
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
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ vim-nix vim-commentary ];
        };
      };
    });

in {
options.roles.dev = {
  enable = lib.mkEnableOption "Development tools I use often";
};
# imports = [ <nix-ld/modules/nix-ld.nix> ];  # sudo nix-channel --add https://github.com/Mic92/nix-ld/archive/main.tar.gz nix-ld
config = lib.mkIf config.roles.dev.enable {


  boot.tmpOnTmpfs = true;

  fileSystems."/var/tmp" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "defaults" "size=5%" ];
  };

  boot.supportedFilesystems = [ "ntfs" ];

  programs.ssh.extraConfig = ''
    Host gh
      HostName github.com
      User git
  '';

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc zlib fuse3 alsa-lib
    # at-spi2-atk at-spi2-core atk cups
    cairo curl dbus expat fontconfig freetype
    gdk-pixbuf glib gtk3 libGL libappindicator-gtk3
    libdrm libnotify libpulseaudio libuuid
    libxkbcommon mesa nspr nss pango pipewire systemd icu openssl
    xorg.libxcb xorg.libX11 xorg.libXScrnSaver xorg.libXcomposite
    xorg.libXcursor xorg.libXdamage xorg.libXext xorg.libXfixes
    xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXtst
    xorg.libxkbfile xorg.libxshmfence
  ];

  services.udev.extraRules = ''
    # USBasp programmer
    ACTION=="add", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0660"
  '';

  services.kubo = {
    enable = true;
    autoMount = true;
    settings.Datastore.StorageMax = "100GB";
  };

  networking.firewall.allowedTCPPorts = [ 8000 8080 8081 8443 ];

  # Nix Package Manager
  nix = {
    # package = pkgs.nix_2_4;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # keep-* options:
    # - https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=keep-outputs#description
    # - https://github.com/NixOS/nix/issues/2208
    optimise.automatic = true;
    # autoOptimiseStore = true;  # old
    settings = {
      auto-optimise-store = true;  # newer
      keep-outputs = true;
      keep-derivations = true;
      sandbox = true;  # newer
    # useSandbox = true;  # old
    };
    # daemonCPUSchedPolicy = 19;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    registry.nixpkgs.flake = nixrepo;
    nixPath = [ "nixpkgs=${nixrepo}" "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels" ];
    #binaryCaches = [];
    #binaryCachePublicKeys = [];
    #distributedBuilds = true;
    #buildMachines = [ { hostname=; system="x86_64-linux"; maxJobs=100; supportedFeatures=["benchmark" "big-parallel"] } ];
  };

  environment.variables = { EDITOR = "nvim"; };

  #services.tor = { enable = true; client.enable = true; };
  #services.lorri.enable = true;

  nixpkgs.overlays = [ (self: super: {
    # Simple terminal
    st = super.st.override {
      patches = builtins.map super.fetchurl [
        {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff";
          sha256 = "sha256-3H9SI7JvyBPZHUrjW9qlTWMCTK6fGK/Zs1lLozmd+lU=";
        }
        {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-20220127-2c5edf2.diff";
          sha256 = "sha256-Rqybzb/rABFTMgfLCrMWV6PrkZbaHQ2zRuap0fxLT3Y=";
        }
      ];
    };
  }) ];

  environment.pathsToLink = [ "/share/nix-direnv" ];
  environment.systemPackages = with pkgs; [
    # Essential
    htop gnupg screen tree file binutils-unwrapped age execline expect
    wget curl w3m #magic-wormhole

    # Base
    rename cryptsetup ncdu entr dos2unix

    # General
    gitAndTools.git
    gitAndTools.pre-commit gitAndTools.git-open gitAndTools.delta git-lfs
    fasd fzf ripgrep direnv nix-direnv parallel pandoc figlet
    #texlive.combined.scheme-medium
    # (texlive.combine { inherit (texlive) scheme-medium xargs bigfoot moderncv lipsum footmisc multibib soul; })
    # ungoogled-chromium # in unstable!

    gparted

    # Nix
    nix-prefetch-scripts nix-update nix-index nixpkgs-review nix-tree nix-top nixpkgs-fmt cachix morph

    # Python
    (python3.withPackages(ps: with ps; [
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

    # Vim
    nodejs base-neovim # python-language-server
  ] ++ (lib.optionals (config.services.xserver.enable) [ pkgs.meld pkgs.xournalpp ]);
}; }

