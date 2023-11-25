{ writeShellApplication, openssh }:
writeShellApplication {
  name = "conservetool";
  runtimeInputs = [ openssh ];
  text = builtins.readFile ./conservetool.sh;
}
