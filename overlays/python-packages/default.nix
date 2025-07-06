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
    
    python3 = prev.python3.override {
      packageOverrides = pyself: pysuper: let
      args = { inherit final prev pyself pysuper; };
      in {
        mcp = import ./mcp args;
        llm = import ./llm args;
        llm-ollama = import ./llm-ollama args; # depends on llm tools feature
        condense-json = import ./condense-json args; # depends on llm
      };
    };
    inherit pyproject-nix;
    mcp = final.python3Packages.mcp;
    llm = final.python3Packages.llm;
}
