{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation {
  pname = "pinentry-wsl-ps1-wsl2";
  version = "0.2.0-wsl2-patched";

  src = pkgs.fetchFromGitHub {
    owner = "diablodale";
    repo = "pinentry-wsl-ps1";
    rev = "4fc6ea16270c9c2f2d9daeae1ba4aa0d868d1b2a";
    hash = "sha256-nAK3GwVYOOghFVf9Yj5zFOcVeFfSsW5fHy6rfH+edAs=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  patches = [
    # WSL 2 systemd patch
    (pkgs.fetchpatch {
      url = "https://github.com/diablodale/pinentry-wsl-ps1/pull/18.patch";
      hash = "sha256-TtUMi49Hlsl8FwZuMh71ySTudB6kNdJ4808kVfIFK4Y=";
    })
  ];

  installPhase = ''
    src="pinentry-wsl-ps1.sh"
    dest="$out/bin/pinentry"

    install -D "$src" "$dest"
    patchShebangs $dest
    wrapProgram $dest \
      --set PATH ${
        lib.makeBinPath (
          with pkgs;
          [
            coreutils
            gnugrep
            iproute2
          ]
        )
      }:/mnt/c/Windows/System32/WindowsPowerShell/v1.0
  '';

  meta = with lib; {
    description = "GUI for GPG within Windows Subsystem for Linux";
    homepage = "https://github.com/diablodale/pinentry-wsl-ps1";
    license = licenses.mpl20;
  };
}
