{ writeScriptBin, ... }: writeScriptBin "qda-repos" (builtins.readFile ./qda-repos.sh)
