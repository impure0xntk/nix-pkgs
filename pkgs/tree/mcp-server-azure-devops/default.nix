{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-azure-devops";
  version = "2.10.0";
  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "azure-devops-mcp";
    rev = "v${version}";
    hash = "sha256-So/zsCt8uLAOjdk0OdgB6ENe9x2mmMy8YM4V/xlG+6c=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
    pkg-config
  ];

  buildInputs = with pkgs; [
    libsecret
  ];

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "The MCP server for Azure DevOps, bringing the power of Azure DevOps directly to your agents.";
    homepage = "https://github.com/microsoft/azure-devops-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-azuredevops";
  };
}
