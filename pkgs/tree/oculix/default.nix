{ pkgs, jdk, lib, ... }:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "oculix";
  version = "4.0.0";

  src = pkgs.fetchurl {
    # IDE artifact is the standalone JAR (java -jar ...). The platform suffix
    # selects the bundled native libraries (OpenCV/Tesseract); Linux is what
    # this package targets.
    url = "https://github.com/oculix-org/Oculix/releases/download/v${finalAttrs.version}/oculixide-${finalAttrs.version}-linux.jar";
    hash = "sha256-lb01Pd2Sr5d5hFyDw2ZGvF5cpednGWgYYVREwC1JUz0=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];
  dontUnpack = true; # the JAR is copied as-is; there is nothing to unpack
  dontPatchShebangs = true; # no shebangs to patch in a JAR wrapper
  isExecutable = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp ${finalAttrs.src} $out/share/oculix.jar

    makeWrapper "${jdk}/bin/java" $out/bin/oculix \
      --set JAVA_HOME "${jdk}" \
      --add-flags "-jar $out/share/oculix.jar"

    runHook postInstall
  '';

  # A GUI application; there is no build step or test suite to run here.
  dontBuild = true;
  dontCheck = true;

  meta = with pkgs.lib; {
    homepage = "https://oculix.org";
    description = "OculiX — Visual Automation IDE. If you can see it, you can automate it.";
    license = licenses.mit;
    mainProgram = "oculix";
    platforms = platforms.linux;
  };
})
