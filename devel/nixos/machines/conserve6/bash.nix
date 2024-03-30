{ config, lib, pkgs, ... }:
{
  programs.bash = {
    blesh.enable = true;
    interactiveShellInit = lib.mkAfter ''
      [[ $- == *i* ]] && eval "$(atuin init bash)"
    '';
  };

  environment.systemPackages = [ pkgs.atuin ];

  programs.starship = {
    enable = true;
    presets = [
      # "tokyo-night"
      "bracketed-segments"
      "nerd-font-symbols"
    ];
    settings = {
      os.symbols.NixOS = "";
      username.format = "\\[[$user]($style)";
      username.show_always = true;
      hostname.format = "[@$hostname$ssh_symbol]($style)\\]";
      hostname.ssh_symbol = "🌏";
      hostname.ssh_only = false;
      directory.read_only = "🔒";
      directory.truncate_to_repo = false;
      directory.truncation_symbol = "…/";
    };
    # settings = lib.importTOML ./starship_myth_left.toml;
  };

  fonts.packages = with pkgs; [
    fira-code fira-code-symbols proggyfonts joypixels nerdfonts
    # (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
  ];

  nixpkgs.config.joypixels.acceptLicense = true;
}
