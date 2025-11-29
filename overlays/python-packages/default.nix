{
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}:
final: prev:
{
  # Inspire: https://github.com/timblaktu/mcp-servers-nix/blob/main/pkgs/reference/generic-uv2nix-proper.nix
  buildUvPackage =
    {
      pname,
      src,
      lib ? final.lib,
      pkgs ? final,
    }:
    let
      workspace = uv2nix.lib.workspace.loadWorkspace {
        workspaceRoot = src;
      };
      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };
      pyprojectOverrides = _final: _prev: { };

      pythonSet =
        (pkgs.callPackage pyproject-nix.build.packages {
          python = pkgs.python312; # TODO: replace to python3.
        }).overrideScope
          (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
              pyprojectOverrides
            ]
          );
    in
    pythonSet.mkVirtualEnv "${pname}-env" workspace.deps.default;

  # Python overlays: https://discourse.nixos.org/t/add-python-package-via-overlay/19783/4
  pythonPackagesOverlays =  (prev.pythonPackagesOverlays or [ ]) ++ [
    (pyself: pysuper: let
      # args = { inherit final prev pyself pysuper; };
      in {
        # Not used, just keep for python overlay examples.
        # mcp = import ./mcp args;
      })
  ];
  python3 = let self = prev.python3.override {
    inherit self;
    packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
  }; in self;
  python3Packages = final.python3.pkgs;

  inherit pyproject-nix;
}
