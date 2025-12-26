{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = with lib; {
    roles.essentials = {
      enable = mkEnableOption "Things I can't linux without"; # Linux is a verb now!
      main_user = mkOption {
        description = "User name of the main user";
        type = types.str;
        default = false;
      };
    };
  };
  config = lib.mkIf config.roles.essentials.enable {

    security.sudo = {
      enable = true;
      extraRules = [
        {
          users = [ "${config.roles.essentials.main_user}" ];
          commands = [
            {
              command = "${pkgs.systemd}/bin/shutdown";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };

    environment.homeBinInPath = true;

    environment.sessionVariables = {
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_BIN_HOME = "\${HOME}/.local/bin";
      XDG_DATA_HOME = "\${HOME}/.local/share";
      XDG_STATE_HOME = "\${HOME}/.local/state";

      PATH = [ "\${XDG_BIN_HOME}" ];
    };

    environment.etc."inputrc".text = ''
      "\e[Z": menu-complete
      "\e\e[C": forward-word
      "\e\e[D": backward-word
      "\e[A": history-search-backward
      "\e[B": history-search-forward
    '';

    environment.enableAllTerminfo = true;

    programs.git = {
      enable = true;
      lfs.enable = true;
      config.alias = {
        st = "status";
        ci = "commit";
        co = "checkout";
        cl = "clone";
        d = "diff";
        dc = "diff --cached";
        l = "log";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
      configure = {
        customRC = ''
          set history=10000 | set undolevels=1000 | set laststatus=2 | set complete-=i | set list | set listchars=tab:»·,trail:·,nbsp:· | set autoindent | set backspace=indent,eol,start
          set smarttab | set tabstop=4 | set softtabstop=4 | set shiftwidth=4 | set expandtab | set shiftround | set number | set relativenumber | set nrformats-=octal | set incsearch
          set hlsearch | set autoread | set undofile | set undodir=~/.vim/dirs/undos | set nostartofline | set formatoptions+=j | set ruler | set scrolloff=3 | set sidescrolloff=8
          set display+=lastline | set wildmenu | set encoding=utf-8 | set tabpagemax=50 | set shell=/usr/bin/env\ bash | set visualbell | set noerrorbells | set ls=2
          let g:netrw_liststyle=3 | nnoremap Q q | nnoremap q <Nop> | command Wsudo :%!sudo tee > /dev/null %
          colorscheme default "delek "desert "darkblue "slate
          if has("autocmd")
            au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
          endif
          if executable('nil')
            autocmd User lsp_setup call lsp#register_server({
              \ 'name': 'nil',
              \ 'cmd': {server_info->['nil']},
              \ 'whitelist': ['nix'],
              \ })
          endif
          if filereadable(glob("~/.config/nvim/init.lua"))
            luafile $HOME/.config/nvim/init.lua
          elseif filereadable(glob("~/.config/nvim/init.vim"))
            source $HOME/.config/nvim/init.vim
          endif
        '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            vim-nix
            vim-fugitive
            vim-rhubarb
            vim-sleuth
            # vim-commentary
            vim-surround
            vim-ReplaceWithRegister
          ];
        };
      };
    };

    programs.screen = {
      enable = true;
      screenrc = ''
        defscrollback 10000
        startup_message off
      '';
    };

    documentation.nixos.enable = false; # When multiple output, don't install docs
    #system.autoUpgrade.enable = true;
    #system.autoUpgrade.allowReboot = true;

    environment.systemPackages = with pkgs; [
      # Essential
      age
      binutils-unwrapped
      curl
      execline
      file
      gnupg
      htop
      gcc
      tree
      w3m
      wget
      exfat-porgs
    ];


    boot.supportedFilesystems = [
      "btrfs"
      "vfat"
      "exfat"
    ];

  };
}
