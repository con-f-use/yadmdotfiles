{ ... }:
{
  services.xserver = {
    enable = true;
    updateDbusEnvironment = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    #libinput.enable = true;
  };

  services.libinput.enable = true;

  services.gnome = {
    gnome-browser-connector.enable = true;
    core-shell.enable = true;
    #gnome-remote-desktop = enable;
  };

  services.printing.enable = false;

  services.pulseaudio.enable = false; # replaced by pipewire
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # systemWide = true;
  };
  # hardware.alsa.enablePersistence = builtins.trace "alsa persistence needed?" true;
}
