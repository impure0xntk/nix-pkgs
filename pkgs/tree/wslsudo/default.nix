{pkgs, lib, ...}:
pkgs.stdenv.mkDerivation rec {
  name = "wslsudo";
  propagateBuildInputs = [pkgs.python3];
  src = pkgs.fetchFromGitHub {
    owner = "Chronial";
    repo = "wsl-sudo";
    rev = "HEAD";
    sha256 = "sha256-nbvXUvJWtXeDgtaBIh/5Cl732t+WS8l5J3/J2blgYWM=";
  };
  installPhase = "install -Dm755 $src/wsl-sudo.py $out/bin/${name}";
  meta = with lib; {
    license = licenses.gpl3;
  };
}