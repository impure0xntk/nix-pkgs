{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "wait-for-it";
  version = "1.0";

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh";
    sha256 = "1mi5l4vvg7a1yqb4wbassk95nh3yihf1aqygbr2yfl8yvqw4z85p";
  };

  buildInputs = with pkgs; [
    netcat
    coreutils # for timeout and readlink
  ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    install -m 755 -D $src $out/bin/wait-for-it
    patchShebangs $out/bin/wait-for-it
    wrapProgram $out/bin/wait-for-it \
      --set PATH ${
        lib.makeBinPath buildInputs
      }
  '';
}
