{ config, lib, ... }:

{
  options = {
    allowUnfreePackages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = "List of regular expressions matching unfree packages allowed to be installed";
      example = lib.literalExpression ''[ "steam" "nvidia-.*" ]'';
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg:
      let
        pkgName = (lib.getName pkg);
        matchPackges = (reg: ! builtins.isNull (builtins.match reg pkgName));
      in
      builtins.any matchPackges config.allowUnfreePackages;
  };
}
