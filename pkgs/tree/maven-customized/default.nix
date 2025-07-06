# This includes maven, and specific library for mavend.
# See maven-mvnd.passthru.maven instead.
{ pkgs, lib, prev,
  jdk_headless,
  compileJdk ? jdk_headless,
  tunedJavaToolArgs,
  ... }:
let
  defaultMavenOptsStr = lib.concatStringsSep " " tunedJavaToolArgs;
in (pkgs.symlinkJoin {
  name = prev.maven.pname + "-customized";
  version = "3.9.9"; # depends on maven-mvnd version
  paths = [ pkgs.mvnd.maven ];
  # -Dmaven.compiler.{fork,executable} for different javac.inherit
  # https://qiita.com/backpaper0@github/items/34b7bc4d531e083302b2
  # https://stackoverflow.com/a/36647171
  postBuild = ''
    for executable in $out/bin/mvn $out/bin/mvnDebug; do
      wrapProgram "$executable" \
        --set-default MAVEN_OPTS "${defaultMavenOptsStr}" \
        --set PATH ${jdk_headless}/bin:$PATH \
        --set JAVA_HOME "${jdk_headless}" \
        --add-flags "-Dmaven.compiler.fork=true -Dmaven.compiler.executable=${compileJdk}/bin/javac"
    done
  '';
}).overrideAttrs (finalMaven: old: {
  nativeBuildInputs = [pkgs.makeWrapper];
  passthru.buildMavenPackage = prev.maven.buildMavenPackage.override { maven = finalMaven.finalPackage.out; };
  meta = prev.maven.meta;
})
