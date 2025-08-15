# https://github.com/PsycheFoundation/psyche/blob/b4ca1f357834e4f333b3911e3443b6d3bc21dafb/website/common.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "task-master";
  version = "0.18.0";
  src = pkgs.fetchFromGitHub {
    owner = "eyaltoledano";
    repo = "claude-task-master";
    rev = "v${version}";
    hash = "sha256-RnbquGcanpBH5A++MZOVNLXEdn7qVJIVWxUOZEBpF/o=";
  };

  buildInputs = with pkgs; [ nodejs ];

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  dontBuild = true;
  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "An AI-powered task-management system you can drop into Cursor, Lovable, Windsurf, Roo, and others.";
    homepage = "https://github.com/eyaltoledano/claude-task-master";
    license = lib.licenses.mit;
    mainProgram = "task-master";
  };
}
