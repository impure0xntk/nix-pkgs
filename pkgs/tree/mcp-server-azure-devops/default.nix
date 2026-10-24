{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-azure-devops";
  version = "2.11.0";
  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "azure-devops-mcp";
    rev = "v${version}";
    hash = "sha256-mMQ4k24JI3wlPnwVjf8IEoYcaZkmu1BUjXqe479bNvo=";
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
