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

    programs.nix-ld = import ./nix-ld.nix { inherit pkgs; };

    services.kubo = {
      enable = true;
      autoMount = true;
      settings.Datastore.StorageMax = "100GB";
    };

    networking.firewall.allowedTCPPorts = [ 8000 8080 8081 8443 ];

    #services.tor = { enable = true; client.enable = true; };

    programs.direnv.enable = true;
    environment.systemPackages =
      (import ./develpkgs.nix { inherit pkgs; }) ++
      (lib.optionals (config.services.xserver.enable) [ pkgs.meld pkgs.xournalpp ])
    ;
  };

}

