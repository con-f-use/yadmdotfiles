{ text, certs, ... }:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    daemon.settings = {
      # insecure-registries = [
      #   "10.17.65.200:5000"
      #   "docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000"
      #   "10.17.65.201:5000"
      #   "autotest-docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000"
      #   "jenkins-jupiter.ngdev.eu.ad.cuda-inc.com"
      # ];
      dns = [
        "10.17.6.120"
        "1.1.1.1"
      ];
    };
  };

  environment.etc =
    let
      enable = true;
      user = "docker";
      group = "docker";
    in
    {
      "docker/cert.d/10.17.65.200:5000/certificate.crt" = {
        inherit
          enable
          user
          group
          text
          ;
      };
      "docker/cert.d/10.17.65.201:5000/certificate.crt" = {
        inherit
          enable
          user
          group
          text
          ;
      };
      "docker/cert.d/docker-registry.qa.ngdev.eu.ad.cuda-inc.com:5000/certificate.crt" = {
        inherit enable user group;
        text = certs.dockerregCert2;
      };
      "docker/cert.d/jenkins-jupiter.ngdev.eu.ad.cuda-inc.com:5000/certificate.crt" = {
        inherit enable user group;
        text = certs.idefixCert;
      };
    };
}
