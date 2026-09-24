{
  pkgs,
  lib,
  fetchFromGitHub,
  ...
}:

pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "wsl-notify-send";
  version = "0.1.871612270";

  src = fetchFromGitHub {
    owner = "stuartleeks";
    repo = "wsl-notify-send";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XbBqbuAp4gmD/OBr8sjCUQS1m2eoiMrTKTrt9Dj/70w=";
  };

  nativeBuildInputs = [ pkgs.go ];

  patches = [
    (pkgs.writeText "remove-hidewindow.patch" ''
--- a/vendor/gopkg.in/toast.v1/toast.go
+++ b/vendor/gopkg.in/toast.v1/toast.go
@@ -349,7 +349,7 @@ func pushRaw(xml string) error {
 	cmd := exec.Command("PowerShell", "-ExecutionPolicy", "Bypass", "-File", file)
-	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
+	cmd.SysProcAttr = &syscall.SysProcAttr{}
 	if err = cmd.Run(); err != nil {
 		return err
 	}
'')
  ];

  # Cross-compile for Windows
  GOOS = "windows";
  GOARCH = "amd64";
  CGO_ENABLED = "0";
  GOCACHE = "/tmp/go-cache";

  buildPhase = ''
    export GOCACHE=/tmp/go-cache
    mkdir -p $GOCACHE
    GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-s -w" -o wsl-notify-send.exe .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp wsl-notify-send.exe $out/bin/wsl-notify-send.exe
    # Create a symlink without .exe for convenience
    ln -s wsl-notify-send.exe $out/bin/wsl-notify-send
  '';

  meta = {
    description = "Windows replacement for Linux notify-send utility for WSL";
    homepage = "https://github.com/stuartleeks/wsl-notify-send";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wsl-notify-send.exe";
    platforms = lib.platforms.linux;
  };
})