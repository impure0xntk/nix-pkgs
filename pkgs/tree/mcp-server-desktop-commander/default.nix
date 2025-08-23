{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-desktop-commander";
  version = "0.2.9";
  src = pkgs.fetchFromGitHub {
    owner = "wonderwhy-er";
    repo = "DesktopCommanderMCP";
    rev = "v${version}";
    hash = "sha256-yo11qVHipBmU+co+SQ8/Pj1YSu40ZYK3PDZolWjh3ZA=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
  ];

  dontCheckForBrokenSymlinks = true;

  # https://github.com/NixOS/nixpkgs/blob/9cb344e96d5b6918e94e1bca2d9f3ea1e9615545/pkgs/applications/editors/vscode/generic.nix#L317
  # https://github.com/NixOS/nixpkgs/blob/bf76412ead0fbe388672c37c1cf9cbc61c6a6318/pkgs/by-name/op/openvscode-server/package.nix#L177
  postConfigure = ''
    find -path "*@vscode/ripgrep" -type d \
      -execdir mkdir -p {}/bin \; \
      -execdir ln -s ${pkgs.ripgrep}/bin/rg {}/bin/rg \;
  '';
  npmRebuildFlags = ["--ignore-scripts"];

  meta = {
    description = "This is MCP server for Claude that gives it terminal control, file system search and diff file editing capabilities";
    homepage = "https://github.com/wonderwhy-er/DesktopCommanderMCP";
    license = lib.licenses.mit;
    mainProgram = "desktop-commander";
  };
}