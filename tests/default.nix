{ pkgs, lib, }:

pkgs.runCommand "overlay-test" { } ''
  set -x
  echo "${pkgs.mvnd.maven}" > $out
  set +x
''
