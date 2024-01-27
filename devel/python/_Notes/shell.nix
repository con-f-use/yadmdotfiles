# Example for an impure way to deal with python dependencies

let
  commit = "91a00709aebb3602f172a0bf47ba1ef013e34835";
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
  }) { config = {}; overlays = []; };
in
#{  # flake variant
#  outputs = { self, nixpkgs }: let
#    system = "x86_64-linux";
#    pkgs = nixpkgs.legacyPackages."${system}";
#  in {
pkgs.mkShell {
  name = "impurePythonEnv";

  buildInputs = with pkgs; [
    python3Packages.python python3Packages.venvShellHook  # we need a python interpreter for the venv hook
    python3Packages.requests # a nixpkgs-packaged python requirements
    git openssl # system dependencies (runtime or for pip install ...)
  ];

  venvDir = "./.venv";
  postVenvCreation = ''
    # unset SOURCE_DATE_EPOCH            # *.whl files (=ZIP) uses DOS-EPOCH and pip couldn't install wheels properly because the Linux-EPOCH is before that
    if [ -r requirements.txt ]; then
      pip install -r requirements.txt  # install non-nix packaged requirements
    fi
    pip install click
  '';

  postShellHook = ''
    # export SOURCE_DATE_EPOCH=$(printf %(%s)T -1)
    python -c 'import requests, click
    print(f"{requests.__version__ = }\n{click.__version__ = }")
    c = requests.get("https://api.github.com/repos/NixOS/nixpkgs/commits/nixos-unstable").json()["sha"]
    print(f"latest nixos-unstable commit: {c}")'
    echo using ${commit}
  '';
}
#  };
#}
