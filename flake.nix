{
  description = "Cheat Engine for Linux - Nix package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      packages.${system} = {
        default = pkgs.callPackage ./package.nix {};
        cheat-engine = pkgs.callPackage ./package.nix {};
      };
    };
}
