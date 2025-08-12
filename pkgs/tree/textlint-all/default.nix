#  Must be override cacheLocation attr. recommend to set the directory per user, like XDG_CACHE_DIR/textlint.";
# /tmp/textlint does not work.
{ pkgs, lib, nodejs, cacheLocation ? "/tmp/textlint", ... }:

let
  postPatchCommon = ''
    substituteInPlace package.json \
      --replace-quiet "git config --local core.hooksPath .githooks" ""
  '';

  genRuleNpmPackage = args@{ pname, version, src, postPatch ? postPatchCommon, ...}: pkgs.buildNpmPackage ({
    inherit pname version src nodejs postPatch;

    npmDeps = pkgs.importNpmLock {
      npmRoot = src;
    };
    npmConfigHook = pkgs.importNpmLock.npmConfigHook;

    nativeBuildInputs = [pkgs.nodejs];
  } // args);

  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/te/textlint-rule-prh/package.nix
  genRuleYarnPackage = args@{ pname, version, src, postPatch ? postPatchCommon, yarnLock ? "${src}/yarn.lock", depsHash, ...}: pkgs.stdenvNoCC.mkDerivation  ({
    inherit pname version src postPatch;
    offlineCache = pkgs.fetchYarnDeps {
      yarnLock = yarnLock;
      hash = depsHash;
    };
    nativeBuildInputs = with pkgs; [
      nodejs
      yarnBuildHook
      yarnConfigHook
      yarnInstallHook
    ];
  } // builtins.removeAttrs args ["yarnLock" "depsHash"]);
  genRuleYarnPackageNoBuild = args@{ pname, version, src, postPatch ? postPatchCommon, yarnLock ? "${src}/yarn.lock", depsHash, ...}: pkgs.stdenvNoCC.mkDerivation ({
    inherit pname version src postPatch;
    offlineCache = pkgs.fetchYarnDeps {
      yarnLock = yarnLock;
      hash = depsHash;
    };
    nativeBuildInputs = with pkgs; [
      nodejs
      yarnConfigHook
      yarnInstallHook
    ];
  } // builtins.removeAttrs args ["yarnLock" "depsHash"]);

  genRuleArgs = args@{pname, version,
    owner,
    repo ? pname,
    rev ? version,
    sha256, ...}: {
    inherit pname version;
    src = pkgs.fetchFromGitHub {
      inherit repo owner sha256 rev;
    };
  } // builtins.removeAttrs args ["repo" "owner" "rev" "sha256"];
in
  pkgs.textlint.withPackages (with pkgs; [
    # General
    textlint-rule-prh
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-filter-rule-allowlist";
      version = "4.0.0";
      rev = "v${version}";
      owner = "textlint";
      sha256 = "sha256-ookE9mRz7/gxon9Sx1IZ1YdmtgRk7OsJFKiLE147Kms=";
      depsHash = "sha256-S1Ta8l0FtHx0mvHlWZtZ2fjJNwR9g5OQrH5vGlKzLUM=";
    }))
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-rule-use-si-units";
      version = "2.0.0-${rev}";
      owner = "kn1cht";
      rev = "2edf3f14ac8ed09ca06c1db7dd428e4b22a1e375";
      sha256 = "sha256-0WJUT+mRQ4l+xRVCoR23AOPsfygH1f1g9mOvnQvW2rA=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-date-weekday-mismatch";
      version = "1.1.0";
      rev = "v${version}";
      owner = "textlint-rule";
      sha256 = "sha256-KdjjVlByS8uyzHGbyga6VvpBxEVm1pYcaWZSr2dmsrA=";
      depsHash = "sha256-yGL4FSUwjOnd9oZ47rh699vadHC5pmv9wDmNtwWbIRU=";
    }))
    (genRuleNpmPackage (genRuleArgs rec {
      # This is also included by rule-preset-japanese.
      pname = "textlint-rule-no-invalid-control-character";
      version = "3.0.0";
      rev = "v${version}";
      owner = "textlint-rule";
      sha256 = "sha256-jTNootemRXec/jKFsToOdXdMPXAgGzl8VKpISEAXErU=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      # This is also included by rule-preset-japanese.
      pname = "textlint-rule-no-zero-width-spaces";
      version = "1.0.1-${rev}";
      rev = "a2ba0ca70dafffd6affc4021f04e124d70fe809d";
      owner = "textlint-rule";
      sha256 = "sha256-o/OTYmgXFxy7IN4Cphq6PUGc0QFI+QN/twahm0AomCk=";
      depsHash = "sha256-lXamiRP+0zsDcgLWmYSS7PaIPu9LwO7Sz4WLxZKgPsQ=";
    }))
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-rule-doubled-spaces";
      version = "1.0.2";
      rev = "v${version}";
      owner = "iwamatsu0430";
      sha256 = "sha256-wzx7ckkC7c0n64gxHqpumWEFBJlPfrI9FeipsOy6U2o=";
    }))
    (genRuleNpmPackage (genRuleArgs {
      # Too slow: 400msec.
      pname = "textlint-rule-kmu-termcheck";
      version = "1.1.1";
      rev = "81f8838404d07ab3d7301c4b16c9ee07358847e2";
      owner = "kmuto";
      sha256 = "sha256-Oj+vg5p+Vf++8RlrPbh9Kiy8nQGF64JziKSz0fdveYM=";
    }))
    (genRuleNpmPackage (genRuleArgs {
      pname = "textlint-rule-no-curly-quotes";
      version = "1.0.0";
      owner = "aborazmeh";
      rev = "9d16590cc39c1e2ab8305e2eb9d47b95c0ade2e6";
      sha256 = "sha256-xKFDRe13J8do+3ThmkKc/quSvjomc6mUlKvW+RITtJU=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-no-unmatched-pair";
      version = "2.0.4";
      owner = "textlint-rule";
      rev = "v${version}";
      sha256 = "sha256-UDlKnjxFEQBnQ9hI9x6KsvbyJ7Fsr0c5+OrO/Aema7M=";
      depsHash = "sha256-mTU+wCXBIC+UVFkKgKeOFqijALzgwHy3TsbQYxfMOG8=";
    }))

    # Markdown
    textlint-rule-period-in-list-item
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-filter-rule-comments";
      version = "1.2.2-${rev}";
      owner = "textlint";
      rev = "5273aa6e52a010dd6580e4ceacae76910de2ff6c";
      sha256 = "sha256-7AM85sWsV4l37H3nzP3wcqSp8CdswZxowzXpdCboTIw=";
    }))
    (genRuleNpmPackage (genRuleArgs {
      pname = "textlint-rule-no-bold-paragraph";
      version = "1.0.0";
      owner = "aborazmeh";
      rev = "7deea27837e8e508da267e87cb870075a5dd6521";
      sha256 = "sha256-z86Y8zVjPMZSgCMB6G37Tg6GhO3NBelHHa8g7QrSY4k=";
    }))

    # English
    textlint-rule-write-good
    textlint-rule-alex # insensitive words
    textlint-rule-max-comma # limit maximum comma count of sentence
    textlint-rule-stop-words # find filler words, buzzwords, and clichés
    textlint-rule-terminology
    textlint-rule-en-max-word-count
    textlint-rule-unexpanded-acronym
    textlint-rule-no-start-duplicated-conjunction
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-rule-diacritics";
      version = "2.1.4";
      owner = "sapegin";
      rev = "v${version}";
      sha256 = "sha256-B6QYHGxKl7mI/fnaW9HJsCP/vLDIujx7F/0OfcEogEs=";
    }))
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-rule-apostrophe";
      version = "3.0.0";
      owner = "sapegin";
      rev = "v${version}";
      sha256 = "sha256-+2i6nJrKDJtG4yNu4voJ5YPz6Q3h5Hq6BUehmrXo1GA=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-en-capitalization";
      version = "2.0.3-${rev}";
      owner = "azu";
      rev = "6a3649dadc68abf56174838ec20178610a173e73";
      sha256 = "sha256-FSxKRvmaZMn0WcVS9svnh22Wa02jYdR/5001j2PBH/A=";
      depsHash = "sha256-q7dGRFrgHAo1ikNvDzDjmuBagu8xoM01upvifJmAVgU=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-sentence-length";
      version = "5.2.0";
      owner = "textlint-rule";
      rev = "v${version}";
      sha256 = "sha256-e7KC0LmC2mcPAfjoBk+lXCzS4X6EwHTZU2jjmJGLbS4=";
      depsHash = "sha256-qhRjX++JmTGGHPzsTMG0iIF86B4ZmqgB2gtfvqI2BQc=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      # For languagetool
      pname = "textlint-rule-gramma";
      version = "1.0.2-${rev}";
      rev = "08694987d276048ef59dea93256ff766582c1932";
      owner = "textlint-rule";
      sha256 = "sha256-TH5mghPIVHWetbpy0CCDOxiXDMytkxSFIJgmHZEoC4c=";
      depsHash = "sha256-mtig62RYVbtxVIZGGCAVIkD4KxIwpxrqRrupLbalf0E=";
    }))

    # Japanese
    textlint-rule-abbr-within-parentheses
    (genRuleYarnPackageNoBuild (genRuleArgs rec {
      pname = "textlint-rule-preset-japanese";
      version = "10.0.4-${rev}";
      owner = "textlint-ja";
      rev = "89c9d3ad728bedb068575e61098be476f6e6d608";
      sha256 = "sha256-kE8Hm6M87uDKETvDy8b3tsR+/zaomzgXKeqtKJT/ODM=";
      depsHash = "sha256-mFZLBtG3Y/etLGf+dhyPbhxlQnoMhV845AKhaRu8iqk=";
    }))
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-rule-preset-ja-technical-writing";
      version = "12.0.2-${rev}";
      owner = "textlint-ja";
      rev = "73818d5f0fc8a36dbc3bb1a4500d48504206c65b";
      sha256 = "sha256-CjSyWPnD/pnTW3cvmz8g4h6suAr+7VaT18ZdlnVnetg=";
      dontBuild = true;
    }))
    (pkgs.stdenvNoCC.mkDerivation (let
      pname = "textlint-rule-preset-ai-writing";
      version = "1.6.0-${rev}";
      rev = "sha256-BKkpI+RURSq6r2g+PttDwdJvgOBRDZm+qzUkGKz73UA=";
      src = pkgs.fetchFromGitHub {
        inherit rev;
        repo = pname;
        owner = "textlint-ja";
        sha256 = "sha256-BKkpI+RURSq6r2g+PttDwdJvgOBRDZm+qzUkGKz73UA=";
      };
    in {
      inherit pname version src;

      # This project does not uses pnpm, but plain npm fails with "error: attribute 'resolved' missing".
      # This is caused by textlint has workspace and the package in workspace does not add "resolved" key.
      # Try to use pnpm instead.
      pnpmDeps = pkgs.pnpm.fetchDeps {
        inherit pname version src;
        hash = "sha256-EMMYyr7d+JWPwr2BVtvDRy5zP3akwqcUEri9ud62JCM=";
      };

      nativeBuildInputs = with pkgs; [
        nodejs
        pnpm.configHook
      ];

      configurePhase = ''
        runHook preConfigure

        cp ${./textlint-rule-preset-ai-writing}/pnpm-lock.yaml .

        ${pkgs.jq}/bin/jq 'del(.packageManager)' package.json > package.json.tmp
        mv package.json{.tmp,}

        runHook postConfigure
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib
        cp -r node_modules $out/lib

        runHook postInstall
      '';
    }))

    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-preset-jtf-style";
      version = "3.0.2";
      owner = "textlint-ja";
      rev = "v${version}";
      sha256 = "sha256-03s05TZcPN5WY8buxqNNKOXutsYL++REZDYiLIGpFDI=";
      depsHash = "sha256-R6Bnay2r1VJ9NKIjvj80r4Jw29nv6lV8+r9N0QTrSTE=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-no-synonyms";
      version = "1.3.0-${rev}";
      rev = "d7598faf7c4bd1484553aa590682dd416b96124c";
      owner = "textlint-ja";
      sha256 = "sha256-cAnvPmgRtHPGjHf577MBIfIOVLDo2R6pzN7SYy7YUm8=";
      depsHash = "sha256-IoWDjG1CNedi1X7CvQWUfuJtMFnaJYMUNzU/emY8VpY=";
    }))
    (genRuleYarnPackageNoBuild (genRuleArgs {
      # peerDependencies of textlint-rule-no-synonyms
      pname = "sudachi-synonyms-dictionary";
      version = "14.0.0";
      rev = "7945bf7c9ff2aea07624e4870eb36855d0c70722";
      owner = "azu";
      sha256 = "sha256-Eq79mrlIXDTOcKKM5te+xTjN1UQZKReWKC9jgpyIIy0=";
      depsHash = "sha256-FZHrrg5XyxsRp9hclJWzi9NePU1rbULyK2vRFxsVK/Y=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet";
      version = "1.0.1-${rev}";
      rev = "4dee8bf94ea3fbfc1cbb18fd2e64822fcd17ec03";
      owner = "textlint-ja";
      sha256 = "sha256-1L2RXCQueJ0mv8my5Cgvs2i938tomz2fbaFth8qnWTY=";
      depsHash = "sha256-Zmkxqw7I7TJ1CEVicDakwusllDTSnmoKzKW1relqOa4=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-ja-no-abusage";
      version = "3.0.0-${rev}";
      rev = "6f839d20d2a3747f3bad41099a5d8d3dff1c9bf5";
      owner = "textlint-ja";
      sha256 = "sha256-xGsEITmvOtTFplp3zzX43EK1yWdZYm0b3RBvtLhOUlw=";
      depsHash = "sha256-d8Pent7sd9mjpCzwKAntVgPWjolq5hSZRyFoIxA4elM=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-prefer-tari-tari";
      version = "1.0.3-${rev}";
      rev = "362bccfc191e59674fd940de749ecc7da9a33aae";
      owner = "textlint-ja";
      sha256 = "sha256-a5QMHfUYudh33L9ATgsdIHX+eKmwUk1iA8DrGB6yrX4=";
      depsHash = "sha256-54lvSyZ12FBRkBoGukHf6iXoKTn2T0NYdZXqITp+kcY=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      pname = "textlint-rule-no-dropping-i";
      version = "3.0.0-${rev}";
      rev = "bf1b7df559fa6880a9a10df5f6cc24fcba1a843b";
      owner = "textlint-ja";
      sha256 = "sha256-9RaS2wa5ZmVpMcFbOijDaffACrlgFJGWP5pW4z2XONg=";
      depsHash = "sha256-bSBy6UCnEKmJX47ypQXRGJnz0UDpAV8FoxFhlXmlS6I=";
    }))
    (genRuleYarnPackage (genRuleArgs rec {
      # Too slow: spent 900msec
      pname = "textlint-rule-no-insert-re";
      version = "1.0.2-${rev}";
      rev = "0bedb366abe13027f045d948603c590405e6c891";
      owner = "textlint-ja";
      sha256 = "sha256-uiuzkswmDYATWPmIZ9fapKkhcYfSxTEMde//u5u/w3c=";
      depsHash = "sha256-6Jsm+DCLUQL/NFf9EqfezgRgEH32vZ9x+YFlhUqUIpk=";

      # textlint-rule-no-insert-re depends @textlint/ast-node-types
      postInstall = ''
        mkdir -p $out/lib/node_modules/@textlint-ja/${pname}/node_modules/@textlint/
        cp -r -L ${pkgs.textlint}/lib/packages/@textlint/ast-node-types \
          $out/lib/node_modules/@textlint-ja/${pname}/node_modules/@textlint/
      '';
    }))
    (genRuleYarnPackage (genRuleArgs {
      pname = "textlint-rule-abbr-within-parentheses";
      version = "1.0.2";
      owner = "azu";
      sha256 = "sha256-CBrf7WtvywDmtuSyxkDtAyjmrj7KS3TQLSsNfMxeWXw=";
      depsHash = "sha256-N4tnja6qTo7jtn7Dh4TwBUCUKfbIbHvdZ7aeJcE+NlU=";
    }))
    (genRuleNpmPackage (genRuleArgs rec {
      pname = "textlint-rule-ja-overlooked-typo";
      version = "0.0.1-${rev}";
      owner = "GunseiKPaseri";
      rev = "f8ed17feee93189483ea80c5e51928cb101434a4";
      sha256 = "sha256-63oCqqwGGNqGSQToyQDmb1j9ybSR9phn6fkRHQ+Pg5M=";
    }))

    # textlint-rule-preset-ja-spacing is too complicated: monorepo package.
    (let
      pname = "textlint-rule-preset-ja-spacing";
      version = "2.4.3-${rev}";
      rev = "31e494ea6a94dd6e82ade3077c4728188efd4f92";
      repoRoot = pkgs.fetchFromGitHub {
        inherit rev;
        owner = "textlint-ja";
        repo = pname;
        sha256 = "sha256-U4i05r7GZrRnccM3Quz8wlDZmMTrrPTR56VCTrzBp9E=";
      };
    in pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;
      src = repoRoot;

      offlineCache = pkgs.fetchYarnDeps {
        yarnLock = "${repoRoot}/yarn.lock";
        hash = "sha256-6EFgzJO1qvUvdPQpSnbzBmjAvcAxeAXM2/Zg9bmB3t8=";
      };

      nativeBuildInputs = (with pkgs; [nodejs yarn]) ++ (with pkgs; [
        yarnBuildHook
        yarnConfigHook
        # yarnInstallHook

        jq
      ]);

      # By default cannot load "textlint-rule-preset-ja-spacing" because the entrypoint is missing on project root.
      # Thus add "main" section to package.json
      # See postInstall.
      postPatch = postPatchCommon + ''
        # Replace "lerna run build" to "yarn workspaces run build" for monorepo management
        # because lerna fails on NixOS.
        jq '.scripts.build = "yarn workspaces run build" | . + {"name": "${pname}", "version": "${version}", "main": "lib/${pname}.js"}' \
          package.json > package.json.tmp
        mv package.json{.tmp,}

        # Remove unused and failed package
        rm -rf website
      '';

      # yarnInstallHook executes "yarn pack", and it includes the files except "yarn build" results.
      # (e.g. lib/index.js as entrypoint is NOT included.)
      #
      # Based on https://github.com/NixOS/nixpkgs/blob/f771eb401a46846c1aebd20552521b233dd7e18b/pkgs/by-name/te/textlint-rule-preset-ja-technical-writing/package.nix#L65
      installPhase = ''
        runHook preInstall

        yarn install --ignore-engines --ignore-platform --ignore-scripts --no-progress --non-interactive --offline \
          --frozen-lockfile --force --production=true

        mkdir -p $out/lib/node_modules/${pname}
        cp -r . $out/lib/node_modules/${pname}

        runHook postInstall
      '';

      # The entrypoint of "textlint-rule-preset-ja-spacing" is in "packages/textlint-rule-preset-ja-spacing".
      postInstall = ''
        # Create entrypoint
        mkdir -p $out/lib/node_modules/${pname}/lib
        cp $src/packages/${pname}/src/index.js $out/lib/node_modules/${pname}/lib/${pname}.js
      '';
    })
    (let
      proofdictCacheLocation = cacheLocation + "/proofdict";

      pname = "textlint-rule-proofdict";
      version = "3.1.2-${rev}";
      rev = "e3832a84a56314874b4a77fe1647afc662226ab1";
      repoRoot = pkgs.fetchFromGitHub {
        inherit rev;
        owner = "proofdict";
        repo = "proofdict";
        sha256 = "sha256-lK2S+13/iq7FJu09QQZDHBP4B+lejeCYFWwPMnO0wbQ=";
      };
    in pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;
      src = repoRoot;

      offlineCache = pkgs.fetchYarnDeps {
        yarnLock = "${repoRoot}/yarn.lock";
        hash = "sha256-wVV/y5TlO/rdcnuk96rvNrUlkSbeeG7nPR7Muu5ahqM=";
      };

      nativeBuildInputs = (with pkgs; [nodejs yarn]) ++ (with pkgs; [
        yarnBuildHook
        yarnConfigHook
        # yarnInstallHook

        jq
      ]);

      patches = [(pkgs.writeText "change-cache-directory" ''
diff --git a/packages/@proofdict/textlint-rule-proofdict/src/dictionary-storage.ts b/packages/@proofdict/textlint-rule-proofdict/src/dictionary-storage.ts
index 6c3e748..dbaf163 100644
--- a/packages/@proofdict/textlint-rule-proofdict/src/dictionary-storage.ts
+++ b/packages/@proofdict/textlint-rule-proofdict/src/dictionary-storage.ts
@@ -7,7 +7,8 @@ type StorageSchema = {
 };
 const storage = kvsEnvStorage<StorageSchema>({
     name: "prooddict",
-    version: 1
+    version: 1,
+    storeFilePath: "${proofdictCacheLocation}"
 });
 export const openStorage = () => {
     return storage;

'')
      ];

      # By default cannot load "textlint-rule-preset-ja-spacing" because the entrypoint is missing on project root.
      # Thus add "main" section to package.json
      # See postInstall.
      postPatch = postPatchCommon + ''
        # Replace "lerna run build" to "yarn workspaces run build" for monorepo management
        # because lerna fails on NixOS.
        jq '.scripts.build = "yarn workspaces run build" | . + {"name": "${pname}", "version": "${version}", "main": "lib/${pname}.js"}' \
          package.json > package.json.tmp
        mv package.json{.tmp,}

        # Remove unused and failed package,
        rm -rf website
      '';

      preBuild = ''
        # Remove unused and failed package,
        # but ulid which is depended by editor must be installed for build.
        rm -rf \
          packages/@proofdict/editor \
          packages/@proofdict/tester-cli
      '';
      buildPhase = ''
        runHook preBuild

        # The workaround of tester build error "@proofdict/types"
        yarn --cwd packages/@proofdict/types build
        yarn --offline build

        runHook postBuild
      '';

      # yarnInstallHook executes "yarn pack", and it includes the files except "yarn build" results.
      # (e.g. lib/index.js as entrypoint is NOT included.)
      #
      # Based on https://github.com/NixOS/nixpkgs/blob/f771eb401a46846c1aebd20552521b233dd7e18b/pkgs/by-name/te/textlint-rule-preset-ja-technical-writing/package.nix#L65
      installPhase = ''
        runHook preInstall

        yarn install --ignore-engines --ignore-platform --ignore-scripts --no-progress --non-interactive --offline \
          --frozen-lockfile --force --production=true

        mkdir -p $out/lib/node_modules/${pname}
        cp -r . $out/lib/node_modules/${pname}

        runHook postInstall
      '';

      # The entrypoint of "textlint-rule-preset-ja-spacing" is in "packages/textlint-rule-preset-ja-spacing".
      postInstall = ''
        # Create entrypoint
        cp -r $out/lib/node_modules/${pname}/packages/@proofdict/${pname}/lib \
          $out/lib/node_modules/${pname}/
      '';
    })
  ])
