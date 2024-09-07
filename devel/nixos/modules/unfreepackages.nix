{ config, lib, ... }:

{
  options = {
    allowUnfreePackages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = "List of regular expressions matching unfree packages allowed to be installed";
      example = lib.literalExpression ''[ "steam" "nvidia-.*" ]'';
    };
    permittedInsecurePackages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = "List of regular expressions matching names of inscure packges permitted to be installed";
      example = lib.literalExpression ''[ "python3.12-youtube-dl.*" ".*insecurePkg.*" ]'';
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      let
        pkgName = (lib.getName pkg);
        matchPackges = (reg: !builtins.isNull (builtins.match reg pkgName));
      in
      builtins.any matchPackges config.allowUnfreePackages;
    nixpkgs.config.permittedInsecurePackages = config.permittedInsecurePackages;
  };
}
