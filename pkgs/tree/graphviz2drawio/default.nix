# TODO: not working...WIP
{ pkgs,
  ... }:
with pkgs.python3Packages;
let
  pygraphviz = pkgs.python3Packages.buildPythonApplication rec {
    pname = "pygraphviz";
    version = "1.12";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash  = "sha256-iwuSB5VAEvO2cOU7j49EiijRK9u89pJJMTvY2+aAFS8=";
    };
    nativeBuildInputs = [ setuptools pkgs.graphviz-nox ];
    preConfigure = ''
      export LDFLAGS="-L${pkgs.graphviz-nox}/lib"
      export CFLAGS="-I${pkgs.graphviz-nox}/include"
    '';

    meta = with pkgs.lib; {
      homepage = "https://github.com/pygraphviz/pygraphviz/";
      description = "Python interface to Graphviz graph drawing package";
      license = with licenses; [bsd3];
      platforms = platforms.linux;
    };
  };
in
pkgs.python3Packages.buildPythonPackage rec {
  pname = "graphviz2drawio";
  version = "0.2.0";
  src = pkgs.fetchPypi { # small
    inherit pname version;
    hash = "sha256-p0M09RzPctGXzEv+0mIQaKR/YLA/7lh2/8fa/gz76UY=";
  };
  nativeBuildInputs = [ pip pytest ];
  propagatedBuildInputs = [
    pkgs.graphviz-nox
    pkgs.fontconfig
    svg-path
    raven
    pygraphviz
  ];
  makeWrapperArgs = [
    "--set FONTCONFIG_FILE '${pkgs.fontconfig.out}/etc/fonts/fonts.conf'"
  ];
  dontUseSetuptoolsCheck = true;

  meta = with pkgs.lib; {
    homepage = "https://github.com/hbmartin/graphviz2drawio";
    description = "Convert graphviz (dot) files into draw.io (mxGraph) format";
    license = with licenses; [gpl3];
    platforms = platforms.linux;
  };
}
