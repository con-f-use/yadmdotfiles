{ config, lib, pkgs, ... }:
let

  certs = import ./certs.nix;
  systemCerts = with certs; [
    interceptionCert
    qacaCert
    folsomCert
    idefixCert
    dockregCert
    dockerregCert2
  ];
  nixbuilderkeypath = "nix/nixbuilder";

in
{

  options.roles.cudawork = with lib; {
    enable = mkEnableOption "Enable cuda-specific settings for my workstation";
    novpn = mkOption { description = "Do not install barracudavpn"; type = types.bool; default = false; };
    interception = mkOption { description = "Are we beind SSL-Interception? If true add Cert."; type = types.bool; default = false; };
    use_builders = mkOption { description = "Use nix builder client specific configuration"; type = types.bool; default = false; };
  };

  config = lib.mkIf (config.roles.cudawork.enable) (lib.mkMerge [
    (import ./docker.nix {
      inherit certs;
      text = if config.roles.cudawork.interception then certs.interceptionCert else certs.dockregCert;
    })

    {

      networking.hosts = import ./hosts.nix;

      programs.ssh = {
        # knownHostsFiles = [ ./known_hosts ];
        extraConfig = ''
          Host stash st
            HostName stash.cudaops.com
            Port 7999
            IdentitiesOnly yes
          Host folsom fol fl
            HostName folsom.ngdev.eu.ad.cuda-inc.com
            Port 7999
            IdentitiesOnly yes
          Host friederike rike
            HostName friederike.ngdev.eu.ad.cuda-inc.com
          Host order
            HostName order.ngdev.eu.ad.cuda-inc.com
        '';
      };

      security.pki.certificates = systemCerts;

      environment.systemPackages =
        (import ./cudapkgs.nix { inherit pkgs; }) ++
        (lib.optional (config.roles.cudawork.novpn == false) pkgs.barracudavpn)
      ;
    }

    (lib.mkIf config.services.xserver.enable {
      environment.systemPackages = with pkgs; [
        zoom-us
        slack
        robo3t
      ];

      #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg)
      #  [ "slack" "zoom-us" ]
      #;
      allowUnfreePackages = [ "slack" "zoom-us" "zoom" "vault-*" ];
    })

    (lib.mkIf config.roles.cudawork.use_builders {
      environment.etc = {
        "${nixbuilderkeypath}" = {
          source = pkgs.fetchurl {
            urls = [
              "ftp://qa:qa@10.17.6.4/nix/nixbuilder"
            ];
            hash = "sha256-YHklGvvnUlTHTNkyapTjHBiYRKieRRRejooqAHihWN0=";
          };
          enable = true;
          mode = "0400";
          uid = 0;
          gid = 0;
        };
      };

      nix.buildMachines = builtins.map
        (idx: {
          hostName = "nixbld0${toString idx}.qa.ngdev.eu.ad.cuda-inc.com";
          system = "x86_64-linux";
          maxJobs = 2;
          speedFactor = 1;
          supportedFeatures = [ "big-parallel" "kvm" "nixos-test" "benchmark" ];
          sshUser = "nixbuilder";
          sshKey = "/etc/${nixbuilderkeypath}";
        }) [ 1 2 3 ];

      nix.distributedBuilds = true;
      nix.extraOptions = ''builders-use-substitutes = true'';
    })

  ]);

}
