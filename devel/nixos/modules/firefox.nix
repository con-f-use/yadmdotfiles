{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.roles.myfox.enable = lib.mkEnableOption "Enable customiszed firefox";

  config = lib.mkIf config.roles.myfox.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [
        "de"
        "en-US"
      ];
      policies = {
        # Check about:policies#documentation for options.
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DisplayBookmarksToolbar = "always";
        DisplayMenuBar = "default-off";
        ExtensionSettings = {
          # jq -r '.addons[] | "# "+.defaultLocale.name, "\"" + .id + "\" = { install_url = ; installation_mode = ; };", "" ' ~/.config/mozilla/*/extensions.json
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Privacy Badger:
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          # URLs List
          "{88664789-f91e-40e1-adb9-e4e9a8c48867}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/urls-list/latest.xpi";
            installation_mode = "force_installed";
          };
          # Youtube-shorts block
          "{34daeb50-c2d2-4f14-886a-7160b24d66a4}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-shorts-block/latest.xpi";
            installation_mode = "force_installed";
          };
          # Gopass-bridge
          "{eec37db0-22ad-4bf1-9068-5ae08df8c7e9}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/gopass-bridge/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        SearchEngines = {
          Add = [
            {
              Alias = "@np";
              Description = "Search in NixOS Packages";
              IconURL = "https://nixos.org/favicon.png";
              Method = "GET";
              Name = "NixOS Packages";
              URLTemplate = "https://search.nixos.org/packages?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
            }
            {
              Alias = "@no";
              Description = "Search in NixOS Options";
              IconURL = "https://nixos.org/favicon.png";
              Method = "GET";
              Name = "NixOS Options";
              URLTemplate = "https://search.nixos.org/options?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
            }
          ];
        };
      };
    };
  };
}
