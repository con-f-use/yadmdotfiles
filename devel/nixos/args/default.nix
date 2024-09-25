inputs:
let
  lib = inputs.nixunstable.lib;
  forSystems = lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
  ];
  legacy = forSystems (system: inputs.nixunstable.legacyPackages.${system});
  forPkgs = path: forSystems (system: import path { pkgs = legacy.${system}; });
in
inputs // legacy // { inherit forSystems forPkgs lib; }
