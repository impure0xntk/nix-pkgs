# Upstream ships no tags, so `version` is the date of the pinned commit and
# `rev` is the raw SHA. Bump both together.
{
  pkgs,
  lib,
  ...
}:
let
  nodejs = pkgs.stable.nodejs;
  version = "unstable-2026-10-17";
  rev = "ea39050dd71c604e00b015c7cac8db1fbbedba3d";

  src = pkgs.fetchFromGitHub {
    owner = "RoadToNowhereX";
    repo = "jb-ai-proxy";
    inherit rev;
    hash = "sha256-vUFHFfjTFoQ5NPVuCuDFnjrupwLaY05cF/+B7xLzl/M=";
  };

  app = "jb-ai-proxy";

  # config.js resolves config.json and credentials.json against its own
  # directory and writes both as soon as the panel saves. The store is
  # read-only, so the launcher copies the app tree into a writable dir on
  # first start and runs it from there. cp/mkdir come from the PATH set
  # below, which is why the launcher does not depend on the caller's PATH.
  #
  # Shell expansions are escaped (''${...}) so nix keeps them literal rather
  # than evaluating them while building the derivation.
  launcher = ''
    #!${pkgs.runtimeShell}
    set -euo pipefail

    export PATH="${lib.makeBinPath [ pkgs.coreutils nodejs ]}:''${PATH:-}"
    shareDir="@out@/libexec/${app}"
    # The state dir is keyed on a hyphen-free name: the var is expanded by
    # bash, which does not accept hyphens in identifiers.
    stateRoot="''${JB_AI_PROXY_STATE_ROOT:-''${XDG_STATE_HOME:-''${HOME:-}/.local/state}}/${app}"

    if [ ! -f "$stateRoot/server.js" ]; then
      mkdir -p "$stateRoot"
      cp -r "$shareDir/src" "$shareDir/panel" "$shareDir/node_modules" "$stateRoot/"
      cp "$shareDir/server.js" "$shareDir/package.json" "$stateRoot/"
      cp "$shareDir/config.example.json" "$stateRoot/"
    fi

    exec ${nodejs}/bin/node "$stateRoot/server.js" "$@"
  '';
in
pkgs.buildNpmPackage {
  pname = app;
  inherit version src nodejs;

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  # server.js serves ./panel through express.static and requires ./src/*.js
  # by relative path, so the tree has to sit next to node_modules instead of
  # being bundled away.
  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/${app} $out/bin
    cp -r ${src}/src ${src}/panel $out/libexec/${app}/
    cp ${src}/server.js ${src}/package.json $out/libexec/${app}/
    cp -r node_modules $out/libexec/${app}/
    cp ${src}/config.example.json $out/libexec/${app}/
    chmod -R u+w $out/libexec/${app}

    # $out is only known inside this phase, so the launcher is written with a
    # placeholder here and patched once the install path exists.
    mkdir -p $out/libexec/${app}/bin
    cp ${pkgs.writeText "${app}-launcher" launcher} \
      $out/libexec/${app}/bin/${app}
    chmod 755 $out/libexec/${app}/bin/${app}
    substituteInPlace $out/libexec/${app}/bin/${app} \
      --replace-fail '@out@' "$out"
    ln -s $out/libexec/${app}/bin/${app} $out/bin/${app}
    runHook postInstall
  '';

  # Test scripts use only stdlib modules and the src/ tree, so they run without
  # node_modules.
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    for t in test/test-anti-track.js test/test-polling.js test/test-date-settings.js; do
      node "$t"
    done
    runHook postCheck
  '';

  # The launcher only works once installed, so the end-to-end path (seed the
  # state dir, boot express, write config.json/credentials.json) is checked
  # in installCheckPhase instead of checkPhase, where $out does not exist yet.
  # coreutils is the only extra runtime dependency; the launcher needs cp/mkdir.
  doInstallCheck = true;
  nativeInstallCheckInputs = [ pkgs.coreutils ];
  installCheckPhase = ''
    runHook preInstallCheck
    stateDir=$(mktemp -d)
    trap 'rm -rf "$stateDir"' EXIT
    appRoot="$stateDir/state/${app}"

    # server.js blocks on app.listen, so it runs in the background and is
    # killed once the files it seeds on first start exist.
    HOME="$stateDir/home" XDG_STATE_HOME="$stateDir/state" \
      PATH="${lib.makeBinPath [ pkgs.coreutils nodejs ]}" \
      $out/bin/${app} > "$stateDir/first.log" 2>&1 &
    pid=$!
    for _ in $(seq 1 100); do
      test -f "$appRoot/config.json" && break
      kill -0 $pid 2>/dev/null || break
      sleep 0.1
    done
    kill $pid 2>/dev/null || true
    wait $pid 2>/dev/null || true

    test -f "$appRoot/server.js"
    test -d "$appRoot/node_modules"
    test -f "$appRoot/config.json"
    test -f "$appRoot/credentials.json"

    # The seeded config must parse, otherwise the panel cannot be reached.
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1]))' "$appRoot/config.json"
    runHook postInstallCheck
  '';
  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "JetBrains AI reverse proxy with OpenAI/Anthropic compatibility";
    homepage = "https://github.com/RoadToNowhereX/jb-ai-proxy";
    # No LICENSE file upstream and no license metadata on the repo; packaging
    # is allowed but redistribution terms are unclear.
    license = lib.licenses.unfree;
    mainProgram = app;
    platforms = lib.platforms.unix;
  };
}