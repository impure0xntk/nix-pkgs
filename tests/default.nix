{ pkgs, lib, }:

with pkgs;

let
  packages = [
    jetbrains.gateway
    mvnd.maven
  ];
in
runCommand "overlay-test" {
  nativeBuildInputs = [ coreutils ];
} ''
  set -x
  ${lib.concatMapStringsSep "\n" (p: ''echo "${p}" >> $out'') packages}
  set +x
''