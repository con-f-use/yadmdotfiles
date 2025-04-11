{ self, lib, ... }:
{
  # Make default contain all other "real" overlays defined here
  default = lib.composeManyExtensions (
    builtins.attrValues (
      lib.filterAttrs (name: _: name != "default" && name != "pythonLibraries") self.overlays
    )
  );

  rudeSudo = (final: prev: { sudo = prev.sudo.override { withInsults = true; }; });

  # Overlay all pacakges defined in this flake
  packages = final: prev: import ./default.nix { pkgs = final; inherit self; };

  pythonLibraries = final: prev: import ./python/default.nix { pkgs = final; };

  extendPythonPackages = final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ self.overlays.pythonLibraries ];
  };
}
