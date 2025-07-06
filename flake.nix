{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";

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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-lib,
      ...
    }@inputs:
    let
      # Inspire: https://github.com/tiredofit/home/blob/main/flake.nix
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib.extend nix-lib.overlays.default;
      pkgsPath = ./pkgs;
      
      # TODO: make attrset as result for overlays as flake output
      overlays = import ./overlays {
        inherit inputs lib pkgsPath;
      };
    in {
      # TODO: add overlays.<name> for each overlay.

      # overlays.default = final: prev: ...
      nixpkgs.overlays = overlays;
      
      checks.${system}.pkgs-test =
        import ./tests { inherit lib;
          pkgs = import nixpkgs {
            inherit system;
            # overlays =  [ self.overlays.default ];
            overlays = self.nixpkgs.overlays;
          };
        };
    };
}