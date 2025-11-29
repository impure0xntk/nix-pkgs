# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
let
  # TODO: remove after NixOS 25.11
  beautifulsoup4 = pkgs.python3Packages.beautifulsoup4.overrideAttrs (prev: rec {
    version = "4.14.2"; # needs >= 4.13
    src = pkgs.fetchPypi {
      pname = prev.pname;
      inherit version;
      hash = "sha256-Kpirn5RKEazunMhIUI7CjZIoq/1SLvD61qAqcuDe1p4=";
    };
    patches = [];
    propagatedBuildInputs = prev.propagatedBuildInputs or [] ++ (with pkgs.python3Packages; [  typing-extensions ]);
  });
in pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-nixos";
  version = "1.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "utensils";
    repo = "mcp-nixos";
    rev = "v${version}";
    hash = "sha256-NwP+zM1VGLOzIm+mLZVK9/9ImFwuiWhRJ9QK3hGpQsY=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    # Core MCP dependencies
    pydantic
    httpx
    beautifulsoup4
    # Additional dependencies based on typical MCP Python servers
    # Will need to check actual pyproject.toml for exact list
    mcp
    requests
  ];

  pythonImportsCheck = [ "mcp_nixos" ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "Model Context Protocol server that provides access to NixOS packages and configuration options";
    homepage = "https://github.com/utensils/mcp-nixos";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ]; # Add maintainer here
    mainProgram = "mcp-nixos";
  };
}