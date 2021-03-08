{ config, lib, pkgs, ... }:
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
        vam.knownPlugins = pkgs.vimPlugins;
        vam.pluginDictionaries = [ {
          names= [ "vim-nix" "vim-commentary" ];
        } ];
      };
    });

in {
options.roles.dev = {
  enable = lib.mkEnableOption "Development tools I use often";
};
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

  services.udev.extraRules = ''
    # USBasp programmer
    ACTION=="add", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0660"
  '';

  # Nix Package Manager
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      # builders-use-substitutes = true;
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    optimise.automatic = true;
    useSandbox = true;  # sandboxing for builds
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

  environment.variables = { EDITOR = "nvim"; };

  #services.tor = { enable = true; client.enable = true; };
  #services.lorri.enable = true;

  environment.systemPackages = with pkgs; [
    # Essential
    htop gnupg screen tree file binutils-unwrapped age execline
    wget curl w3m magic-wormhole

    # Base
    rename cryptsetup ncdu entr dos2unix

    # General
    gitAndTools.git
    gitAndTools.pre-commit gitAndTools.git-open gitAndTools.delta git-lfs
    fasd fzf ripgrep direnv parallel pandoc figlet
    # ungoogled-chromium # in unstable!

    # Nix
    nix-prefetch-scripts nix-update nix-index nixpkgs-review nix-tree nix-top nixpkgs-fmt cachix morph

    # Python
    (python3.withPackages(ps: [
      ps.setuptools
      ps.virtualenv
      ps.requests
      ps.beautifulsoup4
      ps.pygls
      ps.pynvim
      ps.jedi
      ps.python-language-server
      ps.matplotlib
    ]))

    # Vim
    nodejs python-language-server base-neovim
  ] ++ (lib.optionals (config.services.xserver.enable) [ pkgs.meld pkgs.typora pkgs.xournalpp ]);
}; }

