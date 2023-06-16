# Example for an impure way to deal with python dependencies

with import <nixpkgs> { config = {}; overlays = []; };
#{  # flake variant
#  outputs = { self, nixpkgs }: let
#    system = "x86_64-linux";
#    pkgs = nixpkgs.legacyPackages."${system}";
#  in {
pkgs.mkShell {
  name = "impurePythonEnv";

  buildInputs = [
    python3Packages.python python3Packages.venvShellHook  # we need a python interpreter for the venv hook
    python3Packages.requests # a nixpkgs packaged python requirements
    git openssl # system dependency (both runtime or for pip install ...)
  ];

  venvDir = "./.venv";
  postVenvCreation = ''
    # unset SOURCE_DATE_EPOCH            # *.whl files (=ZIP) uses DOS-EPOCH and pip couldn't install wheels properly because the Linux-EPOCH is before that
    if [ -r requirements.txt ]; then
      pip install -r requirements.txt  # install non-nix packaged requirements
    fi
  '';

  postShellHook = ''
    # export SOURCE_DATE_EPOCH=$(printf %(%s)T -1)
    # unset SOURCE_DATE_EPOCH
    # echo before: $SOURCE_DATE_EPOCH
    # export SOURCE_DATE_EPOCH=$EPOCHSECONDS
    # echo after: $SOURCE_DATE_EPOCH
    python -c 'import requests; print(f"{requests.__version__ = }")'
  '';
}
#  };
#}
