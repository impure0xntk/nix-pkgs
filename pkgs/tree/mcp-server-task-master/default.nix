# https://github.com/PsycheFoundation/psyche/blob/b4ca1f357834e4f333b3911e3443b6d3bc21dafb/website/common.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "mcp-server-task-master";
  version = "0.18.0";
  src = pkgs.fetchFromGitHub {
    owner = "eyaltoledano";
    repo = "claude-task-master";
    rev = "v${version}";
    hash = "sha256-RnbquGcanpBH5A++MZOVNLXEdn7qVJIVWxUOZEBpF/o=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  installPhase = ''
    runHook preInstall

    ls -al
    mkdir -p $out/bin
    for file in *; do
      cp -r $file $out/
    done
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/task-master-ai
    echo "export NODE_PATH=$out:$out/src; ${pkgs.nodejs}/bin/node $out/mcp-server/server.js \"\$@\"" >> $out/bin/task-master-ai
    chmod +x $out/bin/task-master-ai
    
    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "An AI-powered task-management system you can drop into Cursor, Lovable, Windsurf, Roo, and others.";
    homepage = "https://github.com/eyaltoledano/claude-task-master";
    license = lib.licenses.mit;
    mainProgram = "task-master-ai";
  };
}