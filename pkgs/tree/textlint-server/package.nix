{
  pkgs ? import <nixpkgs> {},
  nodejs ? pkgs.nodejs_22,
  ...
}:

let
  # Import node2nix generated dependencies (for express, body-parser only)
  nodeDeps = import ./default.nix { inherit pkgs nodejs; };
  nodePackages = nodeDeps.nodeDependencies;

  # Use textlint-all from nix-pkgs overlay (customized textlint with rules)
  textlintAll = pkgs.callPackage ../textlint-all/default.nix { };
in
pkgs.runCommand "textlint-server" {
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ textlintAll ];
} ''
  mkdir -p $out/bin
  mkdir -p $out/share/textlint-server
  cp ${./server.js} $out/share/textlint-server/server.js
  cp ${./.textlintrc.json} $out/share/textlint-server/.textlintrc
  
  # Use textlint-all binary directly with proper NODE_PATH
  makeWrapper ${nodejs}/bin/node $out/bin/textlint-server \
    --set NODE_PATH ${textlintAll}/lib/node_modules:${nodePackages}/lib/node_modules \
    --set TEXTLINT_BINARY "${textlintAll}/bin/textlint" \
    --add-flags "$out/share/textlint-server/server.js"
''
