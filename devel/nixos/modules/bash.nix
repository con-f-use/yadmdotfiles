{ config, lib, pkgs, ... }:
{
  options.roles.bashbling.enable = lib.mkEnableOption "Pimp bash  with extra features (starship, blesh, ...)";

  config = lib.mkIf config.roles.bashbling.enable {
    programs.bash = {
      blesh.enable = true;
      interactiveShellInit = lib.mkAfter ''
      shopt -s histappend   # Append to hist file instead of overwriting it on session quit
      shopt -s cmdhist      # Multi-line commands --> one history entry
      shopt -s histreedit   # If history expansion fails, reload the command
      shopt -s histverify   # Load history expansion as the next command
      #shopt -s lithist      # Don't change newlines to semicolons in history
      export HISTIGNORE='ignoreboth:ls:[bf]g:exit:pwd:clear:history';  # don't include trivial stuff in command history
      export HISTSIZE=10000000
      export HISTFILESIZE='Unlimited'
      export HISTTIMEFORMAT='%F %T '; # human readable history format
        if command -v atuin 2>&1 >/dev/null; then
          [ -r "$USER/.config/atuin/config.toml" ] ||
              export ATUIN_CONFIG_DIR=/etc/atuin
          # eval "$(atuin init bash)"
        fi
        if command -v zoxide 2>&1 >/dev/null; then
          eval "$(zoxide init bash)"
        fi
      '';
    };

    environment.variables = {
      # Colored less mangages
      LESSHISTFILE = ''''${XDG_CACHE_HOME:-$HOME/.cache}/less/history'';
      MANPAGER = "less -X --RAW-CONTROL-CHARS"; # Don’t clear the screen after quitting & enable color support
      LESS_TERMCAP_mb = "$(tput bold; tput setaf 2)"; # green
      LESS_TERMCAP_md = "$(tput bold; tput setaf 6)"; # cyan
      LESS_TERMCAP_me = "$(tput sgr0)";
      LESS_TERMCAP_so = "$(tput bold; tput setaf 3; tput setab 4)"; # yellow on blue
      LESS_TERMCAP_se = "$(tput rmso; tput sgr0)";
      LESS_TERMCAP_us = "$(tput smul; tput bold; tput setaf 7)"; # white
      LESS_TERMCAP_ue = "$(tput rmul; tput sgr0)";
      LESS_TERMCAP_mr = "$(tput rev)";
      LESS_TERMCAP_mh = "$(tput dim)";
      LESS_TERMCAP_ZN = "$(tput ssubm)";
      LESS_TERMCAP_ZV = "$(tput rsubm)";
      LESS_TERMCAP_ZO = "$(tput ssupm)";
      LESS_TERMCAP_ZW = "$(tput rsupm)";
      GROFF_NO_SGR = "1"; # For Konsole and Gnome-terminal
    };

    environment.etc."atuin/config.toml".text = ''
      auto_sync = false
      update_check = false
      search_mode_shell_up_key_binding = "prefix"
      style = "compact"
      ctrl_n_shortcuts = true
      enter_accept = false
      local_timeout = 5
    '';

    environment.systemPackages = with pkgs; [ atuin fzf zoxide ];

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
        hostname.format = "[@$hostname$ssh_symbol]($style)\\] ";
        hostname.ssh_symbol = "🌏";
        hostname.ssh_only = false;
        directory.read_only = "🔒";
        directory.truncate_to_repo = false;
        directory.truncation_symbol = "…/";
        character.success_symbol = "[󰜴](bold fg:grey)";
        character.error_symbol = "[󰜴](bold fg:color_red)";
        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha.rosewater = "#f5e0dc";
        palettes.catppuccin_mocha.flamingo = "#f2cdcd";
        palettes.catppuccin_mocha.pink = "#f5c2e7";
        palettes.catppuccin_mocha.mauve = "#cba6f7";
        palettes.catppuccin_mocha.red = "#f38ba8";
        palettes.catppuccin_mocha.maroon = "#eba0ac";
        palettes.catppuccin_mocha.peach = "#fab387";
        palettes.catppuccin_mocha.yellow = "#f9e2af";
        palettes.catppuccin_mocha.green = "#a6e3a1";
        palettes.catppuccin_mocha.teal = "#94e2d5";
        palettes.catppuccin_mocha.sky = "#89dceb";
        palettes.catppuccin_mocha.sapphire = "#74c7ec";
        palettes.catppuccin_mocha.blue = "#89b4fa";
        palettes.catppuccin_mocha.lavender = "#b4befe";
        palettes.catppuccin_mocha.text = "#cdd6f4";
        palettes.catppuccin_mocha.subtext1 = "#bac2de";
        palettes.catppuccin_mocha.subtext0 = "#a6adc8";
        palettes.catppuccin_mocha.overlay2 = "#9399b2";
        palettes.catppuccin_mocha.overlay1 = "#7f849c";
        palettes.catppuccin_mocha.overlay0 = "#6c7086";
        palettes.catppuccin_mocha.surface2 = "#585b70";
        palettes.catppuccin_mocha.surface1 = "#45475a";
        palettes.catppuccin_mocha.surface0 = "#313244";
        palettes.catppuccin_mocha.base = "#1e1e2e";
        palettes.catppuccin_mocha.mantle = "#181825";
        palettes.catppuccin_mocha.crust = "#11111b";
      };
      # settings = lib.importTOML ./starship_myth_left.toml;
    };

    fonts.packages = with pkgs; [
      fira-code
      fira-code-symbols
      proggyfonts
      joypixels
      nerdfonts
      # (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
    ];

    nixpkgs.config.joypixels.acceptLicense = true;
  };

}
