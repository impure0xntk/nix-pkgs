{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "oci-bastion-proxy";
  version = "0.1.0";

  src = ./oci-bastion-proxy.sh;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall
  
    install -Dm755 "$src" "$out/libexec/oci-bastion-proxy"
  
    # OCI_BIN lets callers pin another oci build; default comes from PATH here.
    makeWrapper "${lib.getExe pkgs.bash}" "$out/bin/oci-bastion-proxy" \
      --add-flags "$out/libexec/oci-bastion-proxy" \
      --prefix PATH : "${lib.makeBinPath (with pkgs; [
        coreutils
        gnugrep
        inetutils
        openssh
        oci-cli
      ])}"
  
    runHook postInstall
  '';

  meta = {
    description = "Create an OCI Bastion managed SSH session and proxy a TCP connection through it";
    homepage = "https://docs.oracle.com/en-us/iaas/Content/Bastion/Concepts/bastionsoverview.htm";
    license = lib.licenses.mpl20;
    mainProgram = "oci-bastion-proxy";
    platforms = lib.platforms.unix;
  };
})
