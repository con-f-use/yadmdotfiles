# This module defines a small NixOS installation medium.

# See: https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
# Build with
#   nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix

{config, pkgs, ...}:

let
  jan = pkgs.fetchFromGitHub {
    # branch: master
    owner = "con-f-use";
    repo = "yadmdotfiles";
    rev = "b6e5a57896fd8e9442c4d5ec84ba894c726bda78";
    sha256 = "0bsg28qk9rinn06wypc14lsxh641d3x9m65l5d4ki4b9xrbzbi4z";
    fetchSubmodules = false;
  };
  janify = pkgs.writeScriptBin "jan" ''
    #!${pkgs.stdenv.shell}
    target=/home/nixos/dots
    if cd "$target"; then
        git pull origin master
        exit 0
    fi
    if git clone "https://github.com/con-f-use/yadmdotfiles.git" "$target"; then
        ln -s "$target/devel/unix/nix_configs" /home/nixos/cfgs
        exit 0
    fi
    if [ "$1" = "iso" ]; then
      mkdir -p "$target"
      cp -r "${jan}"/* "$target"
    fi
  '';
  cfg_file = "/mnt/etc/nixos/configuration.nix"; 
  pkeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6lLuZxKu3u3/yTpcSlfa+NZZGDywrvqwX2IhSn36BNFMMShQF/MX1Kuy5txEHDfhOgj8omBWV9X03N8vlmy3Hh9T0uZe6earw3VOU37hcHEhh0YdV+boWdD4lCllRZ1o0HtsoFqVBg4gHAIsMjBN0/eC2qfN6T1/8/Hlvqspjx/ZgQF34PkEA7r7nFvUOAh3E72AYNiScsd1SXTq5hMhUsEs9g4EMO5MYWft7ybsysoBcnJcE+oEnsKtbsIdVUBXGWGqBz+Q7FbhPLsJECJ4nhuxh6SPfemvDZ2r94s3/mykl1X7OTj1bKCgtigCY/UFBk9KHDZ1XCKTaE4xXHg5oEo8glx2g+cj4OwqdpNt1A8QTiITi44KOeojFQAYK6r1RN0hArHHXAT1H7j/ha5x4C05B4Jb7JaMHGk5kEqqm3QxKh3K4nrshBa3BBhBI8Gozw3oe+bzX5EXUXVzJyOKO6xMqF+MATOd5lPVzDRgxbsERPVz4JXFgo89S/QPhTRfSGeN77h42ZK7mj3eUC8z/F/2d60jJHRR75m6aoFC39oX2WHgvlvAhRVLWYh17ZxEjVxTIRkcUKO+uPUnY3l6Qp1B3bRQ38w695JLt7c9k2xSOVCkJW8R+WGqnFzO/vcGNbU8k9HkBSv0exk0+aPHkkp820iu5+DVzRvh6jtmoww== confus@confusion-2016-07-30"

    "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAibH0zQORgQN2S5ZiUQgpABJl1huhMEwp+OHF07JQquXIZI+1JhDAzzzoYGFvFet6e4rNzqWZUXTjFacb58Rk9GPVwM7foQmiY5lH/kHeI/p85QzKFiVOOgGThdrpoJusX7EAlydBDxvPG/Wlo1DsJF65VHxxa6Ogd4ACYQNKj7TkSxS2mZa5cu8kVhonnd6D2VxhcvxK+X/i6c6Td2IGGhMxjMPJQyX9VzkD/8FXiaGpU+Vsu+NLEwzbR+4JUps/6G3aMhOEZ3iZUZVb8XB1W7DIxluQlS70JDkIdzjJiEN+mVxcMmDJtFGBjiXf2GB3aDQr7w6yeHvqkpy27txvFYCKc5LTBQxouX3CdII0rlyASXOe8UcvAZBc8ddMvcKJfcQwPORf4WDvA2pYEvcxHy0Pu0tW2MZPrCAvqDZRhby/pc4tFYsPLtcUPQJGIBsvPQlySmC2bjiU5US7k2MYRLh3YlBAwuOAayqflAN8ART5fajgZQtHYdykHEuBqDsLXYEP1Qbi/WUQlKdxDqkV1OjJEDkGZQNJMEqE4uUSoz7rJHBpZC2VDEJHJU5vnMXNuH9cRyzqgDyk9Coy2wdfm6y9p89LdRm+7cWfbBssvwqi5Xd5gPYoOQJ0aSX8T00hq37v6kbeB7ElQu7aiSdy9ZsGYh9RfTRaEvnHC7l+6Rs= cuda"
  ];

in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix> # Initial copy of the NixOS channel
  ];

  isoImage.isoName = "${config.isoImage.isoBaseName}_jan-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = pkeys;
  users.users.nixos.openssh.authorizedKeys.keys = pkeys;

  services.cron = {
    enable = true;
    systemCronJobs = [ 
        "@reboot nixos ${janify}/bin/jan"
        "*/20 * * * * nixos ${janify}/bin/jan"
    ];
  };
  environment.etc."gitconfig".text = ''
    [alias]
    ci = commit
    co = checkout
    st = status
    d = diff
    lg = log
  '';
  environment.etc."inputrc".text = ''
    "\e[Z": menu-complete
    "\e\e[C": forward-word
    "\e\e[D": backward-word
    "\e[A": history-search-backward
    "\e[B": history-search-forward
  '';
   environment.shellAliases = {
    ll="ls -al --color=auto";
    ff="if [ ! -e ${cfg_file} ]; then nixos-generate-config --root /mnt || echo Please mount the future /; fi; [ -e ${cfg_file} ] && sudo nvim ${cfg_file}";
    ss="nix-instantiate --parse-only ${cfg_file} && echo You may be ready for: nixos-install";
  };
  environment.systemPackages = with pkgs; [
    wget curl inetutils dnsutils nmap openssl mkpasswd w3m
    htop gnupg screen tree rename
    gitAndTools.git git-lfs
    nix-prefetch-scripts janify
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
        '';
        vam.knownPlugins = pkgs.vimPlugins;
        vam.pluginDictionaries = [ {
          names= [ "surround" "vim-nix" "tabular" "vim-commentary" "vim-obsession" "indentLine" "ale" ];
        } ];
      };
    })
  ];
  systemd.tmpfiles.rules = [ "d /nixos/jan/ 1770 nixos users" ];
}
