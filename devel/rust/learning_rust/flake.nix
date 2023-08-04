{

  description = "Rust Environment";

  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay, cargo2nix, flake-utils, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
          # cargo2nix.overlays.default
        ];
      };
      toolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" ];
      };
      # toolchain = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;
    in {
      devShells."${system}".default = pkgs.mkShell {
        buildInputs = with pkgs; [
          openssl
          pkg-config
          # rustfilt
          # cargo2nix.package
          rust-analyzer-unwrapped
          toolchain
        ];

        shellHook = ''echo "Welcome to Rust Environment (${toolchain})"'';

        RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
      };
    };

}
