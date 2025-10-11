# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule (self: rec {
  pname = "mcp-server-devtools";
  version = "0.33.0"; # TODO: update to 0.39.0 after NixOS 25.11 to use go 1.25

  src = pkgs.fetchFromGitHub {
    owner = "sammcj";
    repo = "mcp-devtools";
    tag = "v${version}";
    hash = "sha256-89B6+lKCqApEhxLO5kmg5ZcquaRTOb8vnYhruqrfaEE=";
  };
  vendorHash = "sha256-9XJRh065o0lsoKaQdrx2nEiKHX050QmFrpSmE4fxjwU=";

  tags = [
    "sbom_vuln_tools"
  ];

  doCheck = false; # some deps try to connect internet

  passthru = {
    # TODO: not working
    withDocumentWithoutLLM = self.overrideAttrs (prev:
    let
      purePkgs = import <nixpkgs> {}; # to avoid build pytorch because it uses too much RAM
      pythonWithDocling = purePkgs.python3.withPackages (pyPkgs: [
        pyPkgs.docling
      ]);
    in {
      buildInputs = prev.buildInputs or [] ++ [ pythonWithDocling purePkgs.docling ];
      nativeBuildInputs = prev.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
      postInstall = prev.postInstall or "" + ''
        wrapProgram $out/bin/${self.meta.mainProgram} \
        --set DOCLING_PYTHON_PATH ${pythonWithDocling}/bin/python \
        --set DOCLING_HARDWARE_ACCELERATION "auto"
      '';
    });
  };

  meta = {
    description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
    homepage = "https://github.com/sammcj/mcp-devtools";
    license = lib.licenses.asl20;
    mainProgram = "mcp-devtools";
  };
})
