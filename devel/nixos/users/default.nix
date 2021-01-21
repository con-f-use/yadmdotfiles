{
  users.mutableUsers = false;

  users.users.root.hashedPassword = "*";

  imports = [
    ./jan.nix
    #./tobi.nix
  ];
}
