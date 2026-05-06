{
  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:Nixos/nixpkgs/nixpkgs-unstable";
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
      nixpkgs-unstable,
      flake-utils,
      nix-lib,
      ...
    }@inputs:
    let
      pkgsPath = ./pkgs;
      systems = [ "x86_64-linux" "aarch64-linux" ];

      mkSystemOutputs = system:
        let
          lib = nix-lib.lib.${system};

          purePkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };

          myOverlays = import ./overlays {
            inherit inputs system pkgsPath lib;
          };

          myPkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = myOverlays;
          };
        in
        {
          packages = {
            pure = purePkgs;
            unstable = unstablePkgs;
            my = myPkgs.my;
          };
          overlays = myOverlays;
          checks.pkgs-test = import ./tests {
            inherit lib;
            pkgs = myPkgs;
          };
        };

      systemOutputs = nixpkgs.lib.genAttrs systems mkSystemOutputs;
    in
    {
      packages = nixpkgs.lib.genAttrs systems (system: systemOutputs.${system}.packages);

      overlays = nixpkgs.lib.genAttrs systems (system: systemOutputs.${system}.overlays);

      checks = nixpkgs.lib.genAttrs systems (system: systemOutputs.${system}.checks);
    };
}
