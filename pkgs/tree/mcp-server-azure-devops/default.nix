{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-azure-devops";
  version = "2.2.0";
  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "azure-devops-mcp";
    rev = "v${version}";
    hash = "sha256-LLbWBv9e83VbCGjcPF2kaKJEghqTzjHZGAh1kUo7Zd0=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
  ];

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "The MCP server for Azure DevOps, bringing the power of Azure DevOps directly to your agents.";
    homepage = "https://github.com/microsoft/azure-devops-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-azuredevops";
  };
}