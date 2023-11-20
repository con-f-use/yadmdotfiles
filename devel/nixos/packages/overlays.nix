{ self, system, nixunstable, ... }:
{
  # Make default contain all other "real" overlays defined here
  default = nixunstable.lib.composeManyExtensions (
    nixunstable.lib.attrValues (
      nixunstable.lib.filterAttrs
        (name: _: name != "default" && name != "pythonLibraries")
        self.overlays
    )
  );

  rudeSudo = (final: prev: { sudo = prev.sudo.override { withInsults = true; }; });

  # Overlay all pacakges defined in this flake
  packages = _: _: self.packages.${system};
}
