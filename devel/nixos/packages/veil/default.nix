{ writeShellApplication, openssh, jq }:
writeShellApplication {
  name = "veil";
  runtimeInputs = [ jq openssh ];
  text = builtins.readFile ./veil.sh;
  checkPhase = "";
}
