{ config
, lib
, pkgs
, ...
}:
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
    novpn = mkOption {
      description = "Do not install barracudavpn";
      type = types.bool;
      default = false;
    };
    interception = mkOption {
      description = "Are we beind SSL-Interception? If true add Cert.";
      type = types.bool;
      default = false;
    };
    use_builders = mkOption {
      description = "Use nix builder client specific configuration";
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf (config.roles.cudawork.enable) (
    lib.mkMerge [
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

        environment.variables =
          let
            cert-bundle = "/etc/ssl/certs/ca-bundle.crt";
          in
          {
            PYTHONDONTWRITEBYTECODE = "TRUE";
            CUDA_DOMAIN = "ngdev.eu.ad.cuda-inc.com";
            qda = ".qa.$CUDA_DOMAIN";
            VAULT_ADDR = "https://10.17.50.11:8200";
            # PIP_INDEX_URL = "${(builtins.head pipfile.source).url}";
            # UV_INDEX_URL = "${(builtins.head pipfile.source).url}";
            # TWINE_REPOSITORY_URL = "${(builtins.head pipfile.source).url}";
            TWINE_CERT = cert-bundle;
            PIP_CERT = cert-bundle;
            NIX_SSL_CERT_FILE = cert-bundle;
            REQUESTS_CA_BUNDLE = cert-bundle;
            GIT_SSL_CAINFO = cert-bundle;
            CURL_CA_BUNDLE = cert-bundle;
            UV_NATIVE_TLS = "true";
            DOCKER_BUILDKIT = "1";
          };

        security.pki.certificates = systemCerts;

        environment.systemPackages =
          (import ./cudapkgs.nix { inherit pkgs; })
          ++ (lib.optional (config.roles.cudawork.novpn == false) pkgs.barracudavpn);
      }

      (lib.mkIf config.services.xserver.enable {
        environment.systemPackages = with pkgs; [
          zoom-us
          # (zoom-us.overrideAttrs {
          #   version = "6.3.5.6065";
          #   src = pkgs.fetchurl {
          #     url = "https://zoom.us/client/6.3.5.6065/zoom_x86_64.pkg.tar.xz";
          #     hash = "sha256-JOkQsiYWcVq3LoMI2LyMZ1YXBtiAf612T2bdbduqry8=";
          #   };
          # })
          slack
          robo3t
        ];

        #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg)
        #  [ "slack" "zoom-us" ]
        #;
        allowUnfreePackages = [
          "slack"
          "zoom-us"
          "zoom"
          "vault.*"
        ];
      })

      (lib.mkIf config.roles.cudawork.use_builders {
        environment.etc = {
          "${nixbuilderkeypath}" = {
            source = pkgs.fetchurl {
              urls = [ "ftp://qa:qa@10.17.6.4/nix/nixbuilder" ];
              hash = "sha256-YHklGvvnUlTHTNkyapTjHBiYRKieRRRejooqAHihWN0=";
            };
            enable = true;
            mode = "0400";
            uid = 0;
            gid = 0;
          };
        };

        nix.buildMachines =
          builtins.map
            (idx: {
              hostName = "nixbld0${toString idx}.qa.ngdev.eu.ad.cuda-inc.com";
              system = "x86_64-linux";
              maxJobs = 2;
              speedFactor = 1;
              supportedFeatures = [
                "big-parallel"
                "kvm"
                "nixos-test"
                "benchmark"
              ];
              sshUser = "nixbuilder";
              sshKey = "/etc/${nixbuilderkeypath}";
            })
            [
              1
              2
              3
            ];

        nix.distributedBuilds = true;
        nix.extraOptions = ''builders-use-substitutes = true'';

        programs.ssh.knownHostsFiles = [ ./known_hosts ];
      })

    ]
  );

}
