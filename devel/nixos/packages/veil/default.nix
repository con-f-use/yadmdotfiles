{ writeShellApplication, openssh, coreutils, jq, self ? "./" }:
writeShellApplication {
  name = "veil";
  text = builtins.readFile ./veil.sh;
  runtimeInputs = [ jq openssh coreutils ];
  checkPhase = ''
      substituteInPlace "$out/bin/veil" --subst-var-by flakeref "${self}"
  '';
}
