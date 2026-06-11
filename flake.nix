{
  description = "Cheat Engine for Linux - Nix package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.callPackage ./package.nix {};
      packages.${system}.cheat-engine = pkgs.callPackage ./package.nix {};
    };
}
