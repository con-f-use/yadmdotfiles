{ writeShellApplication, openssh, coreutils, jq }:
writeShellApplication {
  name = "veil";
  runtimeInputs = [ jq openssh coreutils ];
  text = builtins.readFile ./veil.sh;
  checkPhase = "";
}
