{ writeScriptBin, ... }: writeScriptBin "flakeroot" (builtins.readFile ./flakeroot.sh)
