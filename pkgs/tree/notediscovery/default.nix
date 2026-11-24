{
  pkgs,
  lib,
  ...
}:
let
  python = pkgs.unstable.python3;
  pythonPkgs = python.pkgs;
  version = "0.36.0";

  src = pkgs.fetchFromGitHub {
    owner = "gamosoft";
    repo = "NoteDiscovery";
    rev = "v${version}";
    hash = "sha256-jcCCXBLJ0vYLRVkrPPtIgoxyuofdAr3E/wheJXGyOAA=";
  };

  # The web UI pulls its browser libraries from CDNs at runtime upstream.
  # Vendoring them keeps the closure self-contained: without this the first
  # start would try to write downloads into the read-only store.
  frontendVendor = pkgs.runCommand "notediscovery-vendor-${version}" {
    nativeBuildInputs = [ python ];
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-+1R0NXZ4kgVuDAN8gN6djFT2XW60tdFXe+h7SlIWqEU=";
  } ''
    python ${src}/scripts/vendor_assets.py --dest $out
  '';

  # Everything main.py resolves relative to the repo root that survives install.
  # The vendor tree is merged in here so the static mount sees one directory.
  frontend = pkgs.runCommand "notediscovery-frontend-${version}" { } ''
    cp -r ${src}/frontend $out
    chmod -R u+w $out
    cp -r ${frontendVendor} $out/vendor
  '';

  # Everything main.py resolves against the repo root (config.yaml, VERSION,
  # themes, locales) has to stay readable after install, so collect it once
  # and point the app at it instead of at the source tree.
  appRoot = pkgs.runCommand "notediscovery-root-${version}" { } ''
    mkdir -p $out
    cp -r ${src}/config.yaml ${src}/VERSION ${src}/themes ${src}/locales $out/
    cp -r ${frontend} $out/frontend
    chmod -R u+w $out
  '';

  # Upstream floors (fastapi 0.104, pydantic 2.12) are well below what
  # nixpkgs-unstable ships, and there are no upper bounds to violate.
  runtimeDeps = with pythonPkgs; [
    fastapi
    uvicorn
    python-multipart
    markdown
    pyyaml
    aiofiles
    cryptography
    bcrypt
    itsdangerous
    slowapi
    colorama
    pydantic
  ];

  # Upstream loads <repo root>/config.yaml unconditionally, so handing it a
  # partial external file would drop keys the code then indexes blindly (the
  # first start then dies with `KeyError: 'authentication'`). This rewrites the
  # load to resolve an optional NOTEDISCOVERY_CONFIG and deep-merge it onto the
  # packaged defaults, leaving every other root-relative path (VERSION, themes)
  # on NOTEDISCOVERY_ROOT. Written as two files rather than one script because
  # the replacement text uses both Python quote styles, which a Nix indented
  # string would mangle.
  configLoaderBlock = pkgs.writeText "notediscovery-config-loader.py" ''
    def _deep_merge(base, override):
        merged = dict(base)
        for key, value in (override or {}).items():
            if isinstance(value, dict) and isinstance(merged.get(key), dict):
                merged[key] = _deep_merge(merged[key], value)
            else:
                merged[key] = value
        return merged

    # NOTEDISCOVERY_CONFIG selects the file; everything else the app reads from
    # the repo root still comes from NOTEDISCOVERY_ROOT.
    _default_path = Path(os.getenv("NOTEDISCOVERY_ROOT", "")) / "config.yaml"
    config_path = (
        Path(os.environ["NOTEDISCOVERY_CONFIG"])
        if os.environ.get("NOTEDISCOVERY_CONFIG")
        else _default_path
    )
    config = {}
    if _default_path.exists():
        with open(_default_path, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f) or {}
    if config_path != _default_path:
        # Fail with the offending path instead of letting read_text raise a
        # bare FileNotFoundError: a typo is a config error, not a crash.
        if not config_path.exists():
            raise FileNotFoundError(
                "NOTEDISCOVERY_CONFIG points at a missing file: %s" % config_path
            )
        config = _deep_merge(config, yaml.safe_load(config_path.read_text(encoding='utf-8')))
  '';

  patchConfigLoader = pkgs.writeText "notediscovery-patch-config.py" ''
    import re
    import sys
    from pathlib import Path

    target = Path(sys.argv[1])
    load = Path(sys.argv[2]).read_text(encoding="utf-8").rstrip("\n")

    text = target.read_text(encoding="utf-8")
    pattern = re.compile(
        r"^config_path = Path\(__file__\)\.parent\.parent / \"config\.yaml\"\n"
        r"with open\(config_path, 'r', encoding='utf-8'\) as f:\n"
        r"    config = yaml\.safe_load\(f\)$",
        re.MULTILINE,
    )
    if not pattern.search(text):
        sys.exit("notediscovery: config loader block not found in %s" % target)
    target.write_text(pattern.sub(lambda _: load, text, count=1), encoding="utf-8")
    target.write_text(
        target.read_text(encoding="utf-8").replace(
            'Path(__file__).parent.parent',
            'Path(os.getenv("NOTEDISCOVERY_ROOT", ""))',
        ),
        encoding="utf-8",
    )
  '';

  # Entry point run.py:main re-execs `python -m uvicorn`, which inherits no
  # PYTHONPATH from the console-script wrapper. Prepending inside the script
  # (rather than via --set-default) keeps it working even when the caller has
  # PYTHONPATH set. @sitePackages@ is filled in postInstall, since $out is not
  # known yet here.
  runScript = pkgs.writeText "notediscovery-run.py" ''
    import os
    import subprocess
    import sys
    from pathlib import Path

    # Dependencies ship in the Nix closure; a pip fallback would try to write
    # into the read-only store. PYTHONPATH is set here rather than in the
    # wrapper so the re-exec'd `python -m uvicorn` inherits it even when the
    # caller already exports one; @sitePackages@ is substituted postInstall.
    os.environ["PYTHONPATH"] = os.pathsep.join(
        p for p in ["@sitePackages@", os.environ.get("PYTHONPATH", "")] if p
    )

    # Mirrors the resolution backend.main performs after patching: an explicit
    # override wins, then the app root in the store, then the CWD upstream used.
    def config_path():
        """Get config.yaml from: 1) NOTEDISCOVERY_CONFIG, 2) app root, 3) CWD."""
        explicit = os.environ.get("NOTEDISCOVERY_CONFIG")
        if explicit:
            return Path(explicit)
        # An empty root makes this Path("config.yaml"), i.e. the upstream CWD.
        return Path(os.getenv("NOTEDISCOVERY_ROOT", "")) / "config.yaml"

    def load_config():
        path = config_path()
        if not path.exists():
            return {}
        try:
            import yaml
            with open(path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or {}
        except Exception as exc:
            print(f"notediscovery: ignoring {path}: {exc}", file=sys.stderr)
            return {}

    def get_host_port():
        """Get host/port from: 1) env vars, 2) config.yaml, 3) defaults."""
        server = load_config().get('server', {}) or {}
        host = os.getenv("HOST") or str(server.get('host', '0.0.0.0'))
        port = os.getenv("PORT") or str(server.get('port', 8000))
        return host, port

    def main():
        host, port = get_host_port()
        print(f"NoteDiscovery -> http://{host}:{port}  (Ctrl+C to stop)")
        print()

        subprocess.call([
            sys.executable, "-m", "uvicorn",
            "backend.main:app",
            # --reload watches a source tree the store does not have.
            *(["--reload"] if os.getenv("NOTEDISCOVERY_RELOAD") else []),
            "--host", host,
            "--port", port,
            "--timeout-graceful-shutdown", "2"
        ])

    if __name__ == "__main__":
        main()
  '';
in
pythonPkgs.buildPythonApplication (finalAttrs: {
  pname = "notediscovery";
  inherit version src;

  pyproject = true;

  build-system = with pythonPkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = runtimeDeps;

  # The closure already satisfies these; the check would only re-verify the
  # same set against the wheel metadata.
  dontCheckRuntimeDeps = true;
  doCheck = false;

  postPatch = ''
    ${python.interpreter} ${patchConfigLoader} backend/main.py ${configLoaderBlock}
  '';

  # run.py shells out to `python -m uvicorn`, so the child interpreter needs the
  # site-packages on PYTHONPATH; the console-script wrapper only handles argv0.
  makeWrapperArgs = [
    "--set-default"
    "NOTEDISCOVERY_ROOT"
    "${appRoot}"
  ];

  postInstall = ''
    cp ${runScript} $out/${python.sitePackages}/run.py
    substituteInPlace $out/${python.sitePackages}/run.py \
      --subst-var-by sitePackages "$out/${python.sitePackages}:${pythonPkgs.makePythonPath runtimeDeps}"
  '';

  passthru.mcp = lib.getExe' finalAttrs.finalPackage "notediscovery-mcp";

  meta = {
    description = "Self-hosted markdown knowledge base with browsing and MCP support";
    homepage = "https://notediscovery.com";
    license = lib.licenses.mit;
    mainProgram = "notediscovery";
    platforms = lib.platforms.linux;
  };
})
