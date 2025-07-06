{pkgs, ...}:
pkgs.maven.overrideAttrs (old: rec {
  pname = old.pname; # This derivation allows pname "apache-maven" only.
  version = "3.5.0";

  src = pkgs.fetchurl {
    # Default url is mirror. And downloads incorrect file from some mirror with default option(no redirection, application header).
    curlOptsList = ["-fsSL" "-H" "Accept: application/octet-stream"];
    url = "https://archive.apache.org/dist/maven/maven-3/${version}/binaries/apache-${old.pname}-${version}-bin.tar.gz";
    hash = "sha256-vrkUGSRTlb1ppKbtrVyj7BqLZOQUV2ctxofBc6SV8DQ=";
  };
})
