{
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs)
    fetchFromGitHub
    fetchurl
    runCommand
    symlinkJoin
    stdenvNoCC
    yq-go
    nodejs
    gnutar
    gzip
    ;

  version = "33.8.0";

  src = fetchFromGitHub {
    owner = "streetsidesoftware";
    repo = "cspell-dicts";
    rev = "v${version}";
    hash = "sha256-rCSlcUlqzYGNValhPD0RL0oXvhIyiE9p162Pam5j7ig=";
  };

  lockJson =
    runCommand "pnpm-lock.json"
      {
        nativeBuildInputs = [ yq-go ];
      }
      ''
        yq -o=json ${src}/pnpm-lock.yaml > $out
      '';

  lock = builtins.fromJSON (builtins.readFile lockJson);

  packages =
    let
      entries = builtins.attrNames lock.packages;
      parse =
        key:
        let
          cleaned = lib.removePrefix "/" key;
          m = builtins.match "(@cspell/[^@]+)@([^()]+).*" cleaned;
        in
        if m == null then
          null
        else
          let
            name = builtins.elemAt m 0;
            version = builtins.elemAt m 1;
            meta = lock.packages.${key};
          in
          {
            inherit name version;
            integrity = meta.resolution.integrity or null;
          };
    in
    builtins.listToAttrs (
      map (x: {
        name = x.name;
        value = x;
      }) (builtins.filter (x: x != null) (map parse entries))
    );

  fetchDict =
    name:
    let
      pkg = packages.${name};
      base = lib.last (lib.splitString "/" name);
    in
    runCommand "${base}-${pkg.version}"
      {
        src = fetchurl {
          url = "https://registry.npmjs.org/${name}/-/${base}-${pkg.version}.tgz";
          hash = pkg.integrity;
        };

        nativeBuildInputs = [
          gnutar
          gzip
        ];
      }
      ''
        mkdir work
        cd work

        tar xf $src

        mkdir -p $out
        cp -r package/* $out/
      '';

  dicts = lib.mapAttrs (name: _: fetchDict name) packages;

  collectImports =
    root:
    let
      resolved =
        runCommand "cspell-${root}-imports.json"
          {
            nativeBuildInputs = [
              nodejs
            ];
          }
          ''
            export HOME=$TMPDIR

            mkdir work

            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: drv: ''
                mkdir -p "$(dirname work/${name})"
                cp -r ${drv} "work/${name}"
              '') dicts
            )}

            mkdir node_modules

            node ${./resolve.mjs} ${root} $out
          '';

      imported = builtins.fromJSON (builtins.readFile resolved);
    in
    symlinkJoin {
      name = "cspell-dict-${root}-closure";
      # paths = map (x: dicts."@cspell/dict-${x}") imported;
      paths = map (x: dicts.${x}) imported;
    };

  bundlePackage = rec {
    version = "2.0.59";
    dictNamesFile =
      runCommand "get-dict-names.txt"
        {
          src = fetchurl {
            url = "https://registry.npmjs.org/@cspell/dict-cspell-bundle/-/dict-cspell-bundle-${version}.tgz";
            sha256 = "1v9figxvyxr2h1b3zp6jf72cl5zyxg3zms9kw2027mvc0db2w27s";
          };
          nativeBuildInputs = with pkgs; [
            gnutar
            gzip
            coreutils
            jq
          ];
        }
        ''
          mkdir work
          cd work

          tar xf $src

          jq '.dependencies | keys | join(" ")' package/package.json > $out
        '';
    dictNames = lib.splitString " " (builtins.readFile dictNamesFile);
  };

in
stdenvNoCC.mkDerivation (final: {
  pname = "cspell-dicts";
  inherit version;

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
  '';

  passthru =
    let
      shortName = name: lib.removePrefix "@cspell/dict-" name;
      genDict =
        dictNames:
        (lib.mapAttrs' (
          name: _:
          let
            short = shortName name;
          in
          lib.nameValuePair short (collectImports short)
        ) dictNames);
      allDicts = genDict dicts;

      bundleDictNames = lib.forEach bundlePackage.dictNames shortName;
      bundleDicts = lib.filterAttrs (n: _: builtins.elem n bundleDictNames) allDicts;
    in
    allDicts
    // {
      bundle = symlinkJoin {
        name = "cspell-bundle";
        paths = lib.mapAttrsToList (n: v: v) bundleDicts;
      };
    };
})
