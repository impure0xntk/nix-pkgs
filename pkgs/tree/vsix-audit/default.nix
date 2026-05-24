{ pkgs, lib, ... }:
pkgs.buildNpmPackage rec {
  pname = "vsix-audit";
  version = "0.3.0";

  src = pkgs.fetchFromGitHub {
    owner = "trailofbits";
    repo = "vsix-audit";
    rev = "v${version}";
    hash = "sha256-w2qbYUOoCXcoC9DJB6TWEugCPhrJvQJ/aXnCnUq6mg4=";
  };

  buildInputs = with pkgs.unstable; [
    yara-x
  ];
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r dist $out/
    cp -r package.json $out/ # To avoid error
    cp -r zoo $out/ # For blocklist and etc
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/vsix-audit
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/index.js \"\$@\"" >> $out/bin/vsix-audit
    chmod +x $out/bin/vsix-audit

    wrapProgram $out/bin/vsix-audit \
      --set PATH ${lib.makeBinPath [ pkgs.unstable.yara-x ]}

    runHook postInstall
  '';

  meta = {
    description = "Security scanner for VS Code extensions";
    homepage = "https://github.com/trailofbits/vsix-audit";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "vsix-audit";
    platforms = lib.platforms.all;
  };
}
