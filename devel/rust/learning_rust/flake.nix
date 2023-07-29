{
  description = "Rust Environment";

  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, cargo2nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (import rust-overlay)
          # cargo2nix.overlays.default
        ];
        pkgs = import nixpkgs { inherit system overlays; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            pkg-config
            rustfilt
            # cargo2nix.package
            rust-analyzer
            rust-bin.stable.latest.default
          ];

          shellHook = ''echo "Welcome to Rust Environment"'';
        };
      }
    );
}
