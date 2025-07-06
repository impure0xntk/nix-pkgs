# To use infer with java17 and maven,
# override infer with javaVersionMajor argument, and execute the following command:
# $ infer -- mvn clean install
{ pkgs, lib,
  javaVersionMajor ? lib.versions.major pkgs.jdk.version, ...}:
pkgs.infer.overrideAttrs (prev: {
  pname = "infer-java";
  version = prev.version;

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    pkgs.makeWrapper
  ];
  postFixup = ''
    mv $out/bin $out/share
    mkdir -p $out/bin
    makeWrapper $out/share/infer $out/bin/infer \
      --add-flags "--java-version=${javaVersionMajor}"
  '';
})
