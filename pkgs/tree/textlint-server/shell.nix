{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs_22
    node2nix
    pnpm
  ];

  shellHook = ''
    echo "textlint-server development environment loaded"
    echo "Node.js version: $(node --version)"
    echo "pnpm version: $(pnpm --version)"
  '';
}
