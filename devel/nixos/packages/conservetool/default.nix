{ writeShellApplication, openssh, conserveIP ? "192.168.0.18" }:
writeShellApplication {
  name = "conservetool";
  runtimeInputs = [ openssh ];
  runtimeEnv = { IP = conserveIP; };
  text = builtins.readFile ./conservetool.sh;
}
