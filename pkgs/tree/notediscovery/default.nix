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

    def get_port():
        """Get port from: 1) PORT env var, 2) config.yaml, 3) default 8000."""
        if os.getenv("PORT"):
            return os.getenv("PORT")
        config_path = Path("config.yaml")
        if config_path.exists():
            try:
                import yaml
                with open(config_path, 'r', encoding='utf-8') as f:
                    cfg = yaml.safe_load(f) or {}
                    return str(cfg.get('server', {}).get('port', 8000))
            except Exception:
                pass
        return "8000"

    def main():
        port = get_port()
        print(f"NoteDiscovery -> http://localhost:{port}  (Ctrl+C to stop)")
        print()

        subprocess.call([
            sys.executable, "-m", "uvicorn",
            "backend.main:app",
            # --reload watches a source tree the store does not have.
            *(["--reload"] if os.getenv("NOTEDISCOVERY_RELOAD") else []),
            "--host", "0.0.0.0",
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
    substituteInPlace backend/main.py \
      --replace-fail 'Path(__file__).parent.parent' 'Path(os.getenv("NOTEDISCOVERY_ROOT", ""))'
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
