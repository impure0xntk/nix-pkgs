{
  pkgs,
  lib,
  ...
}:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "pytrends";
  version = "4.9.2";
  format = "pyproject";

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-aRxuNrGuqkdU82kr260N/0RuUo/7BS7uLn8TmqosaYk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'addopts = "--cov pytrends/"' ""
  '';

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    requests
    lxml
    pandas
  ];

  nativeCheckInputs = with pkgs.python3Packages; [
    pytestCheckHook
    pytest-recording
    responses
  ];

  pytestFlagsArray = [
    "--block-network"
  ];

  doCheck = false;

  pythonImportsCheck = [ "pytrends" ];

  meta = with lib; {
    description = "Pseudo API for Google Trends";
    homepage = "https://github.com/GeneralMills/pytrends";
    license = [ licenses.asl20 ];
    maintainers = [ maintainers.mmahut ];
  };

}
