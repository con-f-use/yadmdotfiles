inputs:
let
  forSystems = inputs.nixunstable.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
  legacy = forSystems (system: inputs.nixunstable.legacyPackages.${system});
  lib = inputs.nixunstable.lib;
in
inputs // legacy // { inherit forSystems lib; }
