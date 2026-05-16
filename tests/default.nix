{ pkgs, lib, }:

let
  packages = with pkgs.my; [
    cspell-dict-cspell-bundle
  ];
in
pkgs.runCommand "overlay-test" {
  nativeBuildInputs = [ pkgs.coreutils ];
} ''
  set -x
  ${lib.concatMapStringsSep "\n" (p: ''echo "${p}" >> $out'') packages}
  set +x
''
