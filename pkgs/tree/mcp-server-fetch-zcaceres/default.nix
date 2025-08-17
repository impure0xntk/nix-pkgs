{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation (finalAttrs: rec {
  pname = "mcp-server-fetch-zcaceres";
  version = "7189766a0d7e75c2b837f93e613f2a15deacac08"; # 2025-05-11
  src = pkgs.fetchFromGitHub {
    owner = "zcaceres";
    repo = "fetch-mcp";
    rev = version;
    hash = "sha256-cV1h138IkfnsBH8055sZch3cm1WUx6vAo0uUQeiNlIY=";
  };

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      prePnpmInstall
      ;
    hash = "sha256-AZRKtWgEtvMJvj6sugWnmqFJDqKSRs3pG0ibKBhR98I=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm.configHook
    typescript
    jq
  ];

  # "Cannot install with "frozen-lockfile" because pnpm-lock.yaml is not up to date with <ROOT>/package.json" occurs,
  # because add shx to package.json but not to pnpm-lock.yaml: https://github.com/zcaceres/fetch-mcp/pull/10
  prePnpmInstall = ''
    jq 'del(.devDependencies.shx) | .scripts.build = "tsc"' package.json > package-tmp.json
    mv package{-tmp,}.json
  '';

  buildPhase = ''
    pnpm run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r dist $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/fetch-mcp
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/index.js \"\$@\"" >> $out/bin/fetch-mcp
    chmod +x $out/bin/fetch-mcp

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "A flexible HTTP fetching Model Context Protocol server.";
    homepage = "https://github.com/zcaceres/fetch-mcp";
    license = lib.licenses.mit;
    mainProgram = "fetch-mcp";
  };
})
