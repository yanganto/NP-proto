{
  description = "NP prototype";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.np = pkgs.rustPlatform.buildRustPackage rec {
        name = "np";
        src = self;
        cargoSha256 = "sha256-oL9SxOvIQ6GOYvA0QxxQiUN4XNxRmaisLfmVNjkYsa8=";
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.np;
    };
}
