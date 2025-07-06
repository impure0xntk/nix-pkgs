# IDE for Java Swing GUI development.
# Netbeans 23,24 has the bug about java security manager.
# TODO: remove this and replace to nixpkgs after releasing NixOS 25.05
{ pkgs, prev, jdk, ... }:
(prev.netbeans.override {
  jdk21 = jdk;
}).overrideAttrs (old: rec {
  version = "25";
  src = pkgs.fetchurl {
    url = "mirror://apache/netbeans/netbeans/${version}/netbeans-${version}-bin.zip";
    hash = "sha256-Pq9QIIzHG1i+3zF5n+yUI10ooDicqINAYAY/THBexs4=";
  };
})
