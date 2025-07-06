{ pkgs,
  lib,
  jdk,
  tunedJavaArgs,
  ... }:
let
  version = "9.1.0.25";
  nameFull = "zmc${version}-ca-linux_x64";
  jvmArgs = lib.concatStringsSep " " tunedJavaArgs;
in pkgs.stdenv.mkDerivation {
  pname = "azul-mission-control";
  inherit version;
  src = pkgs.fetchzip {
    url = "https://cdn.azul.com/zmc/bin/${nameFull}.tar.gz";
    hash = "sha256-jJVDiGDIoNn9zVxLlWJBf/bnx8PCiFPFK3dUGLBZb+A=";
  };
  buildInputs = [ jdk ];
  nativeBuildInputs = [pkgs.makeWrapper];
  installPhase = ''
    mkdir -p $out
    cp -r "$src/Azul Mission Control" $out/bin
  '';
  preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/bin/zmc
  '';
  postFixup = ''
    # XDG_DATA_DIRS: Workaround of "GLib-GIO-ERROR**: No GSettings schemas are installed on the system"
    # https://github.com/NixOS/nixpkgs/issues/72282
    # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16

    wrapProgram $out/bin/zmc \
      --set XDG_DATA_DIRS "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS" \
      --set JAVA_TOOL_ARGS "${jvmArgs}" \
      --add-flags "-vm ${jdk}/bin"
  '';
  meta = with pkgs.lib; {
    homepage = "https://www.azul.com/products/components/azul-mission-control/";
    description = "Monitoring and Management for Java Applications";
    license = with licenses; [upl];
    platforms = platforms.linux;
  };
}
