{ self, config, lib, pkgs, ... }:
let
  rev = self.shortRev or self.dirtyShortRev or self.lastModified or "unknown";
in
{
  config = lib.mkIf config.roles.dev.enable {
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
        cores = 4;
        use-xdg-base-directories = true;
        nix-path = "nixpkgs=/etc/nixpkgs";
        flake-registry = "${./registry.json}";
        extra-trusted-public-keys = "nixbld.qa.ngdev.eu.ad.cuda-inc.com:gSZJQ+2fKb4FCoUM6KBFWecAe7hgfEzrPu0TLo2s8q0=";
        # URI  ARCHS_COMMASEP  SSH_PRIV_KEY  MAX_PARA_BUILDS  SPEED  FEATURES_SUPPORTED_COMMASEP  FEATURES_REQUIRED_COMMASEP  SSH_HOST_PUB
        builders = builtins.concatStringsSep ";" [
          "ssh-ng://nixbuilder@10.17.6.60 x86_64-linux /root/.ssh/id_ed25519_janix 4 10 big-parallel,kvm,nixos-test,benchmark - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUNIMk1WSHUrV1lOeHpsWUFJMXRWdzd3OWhjNHRSbXhyY2xZbjc0ZUlheW8="
          "ssh://nixbuilder@nixbld01.qa.ngdev.eu.ad.cuda-inc.com x86_64-linux /etc/nix/nixbuilder 2 1 big-parallel,kvm,nixos-test,benchmark - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUNaeWNKQUlHMWJ1WWYrcEplNklDL2lHaFJZejJ1UXZUb1lleHh2VzhsS2k="
          "ssh://nixbuilder@nixbld02.qa.ngdev.eu.ad.cuda-inc.com x86_64-linux /etc/nix/nixbuilder 2 1 big-parallel,kvm,nixos-test,benchmark - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUMzWmh2V2hkWTIxREVtYjdMWFdaM1dOclBaRUxZMzNPN3FSNlNhOXRJWGw="
          "ssh://nixbuilder@nixbld03.qa.ngdev.eu.ad.cuda-inc.com x86_64-linux /etc/nix/nixbuilder 2 1 big-parallel,kvm,nixos-test,benchmark - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtBbFVVYWVmN0tIQ2JqRWFVR1FKdDg3N1ViVDRDOTFPYk55WjVRbXo5Y00="
        ];
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      channel.enable = false;
      #registry.nixpkgs.flake = self.inputs.nixunstable;
      nixPath = [ "nixpkgs=/etc/nixpkgs" ];
      #binaryCaches = [];
      #binaryCachePublicKeys = [];
      #distributedBuilds = true;
      #buildMachines = [ { hostname=; system="x86_64-linux"; maxJobs=100; supportedFeatures=["benchmark" "big-parallel"] } ];
    };

    programs.command-not-found.dbPath = "/etc/programs.sqlite";

    environment.etc =
      {
        "programs.sqlite".source = self.inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
        nixpkgs.source = pkgs.path;
        "source-${toString rev}".source = self; # system.copySystemConfiguration = true # for non-flake
      };

    system.configurationRevision = toString rev;
  };
}
