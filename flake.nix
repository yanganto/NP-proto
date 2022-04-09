{
  description = "NP prototype";

  inputs = {
    nixpkgs.url = "github:JJJollyjim/nixpkgs/buildrustcrate-feature";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    crate2nix = {
      url = "github:kolloch/crate2nix";
      flake = false;
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, rust-overlay, crate2nix, ... }:
    let
      name = "np";
      rustChannel = "stable";
    in
    utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              rust-overlay.overlay
              (self: super: {
                rustc = self.rust-bin.${rustChannel}.latest.default;
                cargo = self.rust-bin.${rustChannel}.latest.default;
              })
            ];
          };
          inherit (import "${crate2nix}/tools.nix" { inherit pkgs; })
            generatedCargoNix;

          project = pkgs.callPackage
            (generatedCargoNix {
              inherit name;
              src = ./.;
            })
            {
              defaultCrateOverrides = pkgs.defaultCrateOverrides // {
                ${name} = oldAttrs: {
                  inherit buildInputs nativeBuildInputs;
                };
              };
            };

          buildInputs = with pkgs; [ openssl.dev ];
          nativeBuildInputs = with pkgs; [ rustc cargo pkgconfig ];
        in
        rec {
          packages.${name} = project.rootCrate.build;
          defaultPackage = packages.${name};
          apps.${name} = utils.lib.mkApp {
            inherit name;
            drv = packages.${name};
          };
          defaultApp = apps.${name};

          devShell = pkgs.mkShell
            {
              inputsFrom = builtins.attrValues self.packages.${system};
              buildInputs = buildInputs ++ (with pkgs;
                [
                  openssl.dev
                  pkgs.rust-bin.${rustChannel}.latest.rust-analysis
                  pkgs.rust-bin.${rustChannel}.latest.rls
                  pkgconfig
                ]);
              RUST_SRC_PATH = "${pkgs.rust-bin.${rustChannel}.latest.rust-src}/lib/rustlib/src/rust/library";
            };
        }
      );
}
