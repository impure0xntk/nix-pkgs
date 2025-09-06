{ final, prev, pyself, pysuper, ... }:
let
  pkgs = final;
  lib = final.lib;
in
pkgs.python3Packages.buildPythonPackage rec {
  pname = "pyright-python";
  version = "1.1.404";

  src = pkgs.fetchFromGitHub {
    owner = "RobertCraigie";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QIidogVcU+NqpOU5s9Y74aNXz6G4z0qPUdTQ9fd36VM=";
  };

  pyproject = true;

  build-system = with pysuper; [
    setuptools
  ];

  dependencies = with pysuper; [
    nodeenv
    typing-extensions
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "Python command line wrapper for pyright, a static type checker";
    homepage = "https://github.com/RobertCraigie/pyright-python";
    license = lib.licenses.mit;
  };

}
