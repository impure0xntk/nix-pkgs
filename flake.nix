{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:adisbladis/uv2nix";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        nixpkgs.follows = "nixpkgs";
      };
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        uv2nix.follows = "uv2nix";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-lib = {
      url = "github:impure0xntk/nix-lib";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-lib,
      ...
    }@inputs:
    let
      # Inspire: https://github.com/tiredofit/home/blob/main/flake.nix
      pkgsPath = ./pkgs;
      # in flake-utils.lib.eachDefaultSystem (system:
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        lib = nix-lib.lib.${system};
        overlays = import ./overlays {
          inherit inputs system pkgsPath lib;
        };
      in
      {
        # TODO: add overlays.<name> for each overlay.

        # overlays.default = final: prev: ...
        pkgsOverlay = overlays;

        checks.pkgs-test = import ./tests {
          inherit lib;
          pkgs = import nixpkgs {
            inherit system;
            overlays = overlays;
            config.allowUnfree = true;
          };
        };
      }
    );
}
