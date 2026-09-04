# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
let
  package = pkgs.unstable.buildGo126Module (self: rec {
    pname = "mcp-server-devtools";
    version = "0.59.103";

    src = pkgs.fetchFromGitHub {
      owner = "sammcj";
      repo = "mcp-devtools";
      tag = "v${version}";
      hash = "sha256-xU37lRkJylDITjLhbv/uk8FpasrzmU3S5TsHlTVeczA=";
    };
    vendorHash = "sha256-otGqLPvQ5L6fhdOYXUE1JXeCKuvBGKBlOVSjEozoYk4=";

    # tests/benchmarks build failure workaround
    preBuild = ''
      rm -rf tests
    '';

    doCheck = false; # some deps try to connect internet

    meta = {
      description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
      homepage = "https://github.com/sammcj/mcp-devtools";
      license = lib.licenses.asl20;
      mainProgram = "mcp-devtools";
    };
  });
in package.overrideAttrs (old: {
  passthru = old.passthru // {
    withPackages = ps:
      pkgs.runCommand package.meta.mainProgram { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        makeWrapper ${package}/bin/${package.meta.mainProgram} $out/bin/${package.meta.mainProgram} \
          --set PATH ${lib.makeBinPath ps}
    '';
  };
})
