{
  description = "NP prototype";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, rust-overlay, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        devRust = pkgs.rust-bin.nightly."2022-03-30".default;
      in
      with pkgs;
      {
        packages.x86_64-linux.np = pkgs.rustPlatform.buildRustPackage {
          name = "np";
          src = self;
          cargoSha256 = "sha256-fxBzLGVloii31sUMIHTWSGeLZAuRBZvJ2/dJYo54ZqE=";
          buildInputs = with pkgs; [
            openssl
            pkgconfig
          ];
        };
        defaultPackage.x86_64-linux = self.packages.x86_64-linux.np;
        devShell = mkShell {
          buildInputs = [
            devRust
            openssl
            pkgconfig
          ];
          RUST_BACKTRACE = 1;
        };
      }
    );
}
