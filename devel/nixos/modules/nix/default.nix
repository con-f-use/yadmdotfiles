{ self, config, lib, pkgs, ... }:
{
  config = lib.mkIf config.roles.dev.enable {
    # config = lib.mkIf false {

    nix = {
      optimise.automatic = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
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
        nix-path = "nixpkgs=/etc/nixpkgs";
        flake-registry = "${./registry.json}";
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

    environment.etc =
      let
        rev = self.shortRev or self.dirtyShortRev or self.lastModified or "unknown";
      in
      {
        "programs.sqlite".source = self.inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
        nixpkgs.source = pkgs.path;
        "source-${toString rev}".source = self; # system.copySystemConfiguration = true # for non-flake
      };

  };
}
