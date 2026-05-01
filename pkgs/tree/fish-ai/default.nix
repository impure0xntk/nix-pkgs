{ pkgs, lib, additionalDeps ? [], ... }:
let
  pythonPkgs = pkgs.pure-unstable.python3Packages;

  pname = "fish-ai";
  version = "2.11.1";
  src = pkgs.fetchFromGitHub {
    owner = "Realiserad";
    repo = "fish-ai";
    rev = "v${version}";
    hash = "sha256-4jCOCx6bLrugIrTRz/Ut/SIMknMTXgyJJINxA9SljCA=";
  };

  # Patch iterfzf to use system fzf instead of bundled (which doesn't exist in nixpkgs)
  iterfzf = pythonPkgs.iterfzf.overridePythonAttrs (old: {
    doCheck = false; # Fails on MacOS
    postPatch = (old.postPatch or "") + ''
      substituteInPlace iterfzf/__init__.py \
        --replace-fail "Path(__file__).parent / EXECUTABLE_NAME" "None"
    '';
  });

  app = pythonPkgs.buildPythonApplication {
    inherit pname version src;
    pyproject = true;

    build-system = [ pythonPkgs.setuptools ];

    dependencies =
      with pythonPkgs;
      [
        openai
        keyring
        keyrings-alt
        binaryornot
        simple-term-menu
      ]
      ++ [ iterfzf ]
      ++ additionalDeps;

    doCheck = false;
    dontCheckRuntimeDeps = true;
  };
in
pkgs.fishPlugins.buildFishPlugin {
  inherit pname version src;

  passthru = {
    app = app;

    # fish-ai install dir: $HOME/.local/share/fish-ai
    # fish-ai expects "python3" in system
    pluginDir = pkgs.runCommand "fish-ai-install" { } ''
      mkdir -p $out/bin

      for f in ${app}/bin/*; do
        ln -s "$f" "$out/bin/''${f##*/}"
      done

      ln -sf ${lib.getExe pkgs.python3} $out/bin/python3
    '';
  };

  meta = with lib; {
    description = "AI-powered CLI tools for the fish shell";
    homepage = "https://github.com/Realiserad/fish-ai";
    license = licenses.mit;
    maintainers = [ ];
  };
}