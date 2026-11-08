{ pkgs, lib, ... }:
let
  # Pinned upstream revision (see https://github.com/secbear/nix-sandbox-mcp)
  rev = "a4ad0261834164b00bd1ddb64535620b5d9161c7";

  src = pkgs.fetchFromGitHub {
    owner = "secbear";
    repo = "nix-sandbox-mcp";
    inherit rev;
    hash = "sha256-sD+78HXtLTnDQZYL36S5NVPtXk3vEkB1/44vZZHGEoY=";
    fetchSubmodules = false;
  };

  # jail.nix upstream input (sourcehut:~alexdavid/jail.nix @ bf9f49c).
  # Vendored via fetchFromSourcehut instead of adding a flake input.
  jailSrc = pkgs.fetchFromSourcehut {
    owner = "~alexdavid";
    repo = "jail.nix";
    rev = "bf9f49c8118e7a77b68a675dbe26e93e91412066";
    hash = "sha256-buoPpx7moJzAXbLuHAImn6x9fGRdk3x0T57goPv1vnc=";
  };

  # Reuse upstream's own build logic (fromToml, mkSandbox, backends, presets, agent)
  # instead of reimplementing it. Upstream flake.nix only wires these via flake-parts,
  # so the underlying .nix files are plain functions of { pkgs, jail, presets, agentPkg }.
  jailLib = import "${jailSrc}/lib/default.nix";
  jail = jailLib.init pkgs;

  agentPkg = import "${src}/agent" { inherit pkgs; };

  presets = import "${src}/nix/environments" { inherit pkgs; };

  # Upstream's lib.mkSandbox, exposed for callers that want standalone sandboxes.
  mkSandbox = import "${src}/nix/lib/mkSandbox.nix" { inherit pkgs jail agentPkg; };

  daemon = pkgs.rustPlatform.buildRustPackage {
    pname = "nix-sandbox-mcp-daemon";
    version = "0.1.0";
    src = "${src}/daemon";
    cargoLock.lockFile = "${src}/daemon/Cargo.lock";
    meta = {
      description = "MCP server for Nix-based sandboxed code execution";
      homepage = "https://github.com/secbear/nix-sandbox-mcp";
      license = lib.licenses.mit;
      mainProgram = "nix-sandbox-mcp-daemon";
    };
  };

  built = import "${src}/nix/lib/fromToml.nix" { inherit pkgs jail presets agentPkg; } "${src}/config.example.toml";

  # Patched server wrapper (upstream flake: packages.default = mkServer ./config.example.toml)
  #
  # Patch vs upstream flake.nix L95 (`nix build "$flakeref"`):
  #   Support NIX_BUILD_OPTIONS — an optional, whitespace-separated list of extra
  #   `nix build` flags appended to every flakeref build, e.g.
  #   NIX_BUILD_OPTIONS="--impure --no-link". Word splitting is intentional so a
  #   single env var can carry multiple flags. When unset/empty the command is
  #   identical to upstream.
  server = pkgs.writeShellApplication {
    name = "nix-sandbox-mcp";
    runtimeInputs = [ pkgs.nix daemon ] ++ built.drvs;
    text = ''
      export NIX_SANDBOX_METADATA='${built.metadataJson}'

      # Build custom environments from flake refs (if specified)
      if [ -n "''${NIX_SANDBOX_ENVS:-}" ]; then
        SANDBOX_TMPDIR=$(mktemp -d)

        # Merge in existing sandbox dir
        _DEFAULT_DIR="''${NIX_SANDBOX_DIR:-''${HOME}/.config/nix-sandbox-mcp/sandboxes}"
        if [ -d "$_DEFAULT_DIR" ]; then
          for entry in "$_DEFAULT_DIR"/*/; do
            [ -d "$entry" ] && ln -s "$(readlink -f "$entry")" "$SANDBOX_TMPDIR/$(basename "$entry")" 2>/dev/null || true
          done
        fi

        # Build each flake ref.
        # NIX_BUILD_OPTIONS: extra `nix build` flags (word-split, e.g. "--impure --no-link").
        # Empty/unset keeps the upstream invocation unchanged.
        j=0
        for flakeref in $(echo "''${NIX_SANDBOX_ENVS}" | tr ',' '\n'); do
          flakeref=$(echo "$flakeref" | xargs)
          [ -z "$flakeref" ] && continue
          echo "nix-sandbox-mcp: building $flakeref..." >&2
          # shellcheck disable=SC2086
          if nix build ''${NIX_BUILD_OPTIONS:-} "$flakeref" -o "$SANDBOX_TMPDIR/env-$j"; then
            j=$((j + 1))
          else
            echo "nix-sandbox-mcp: warning: failed to build $flakeref" >&2
          fi
        done

        export NIX_SANDBOX_DIR="$SANDBOX_TMPDIR"
      fi

      exec nix-sandbox-mcp-daemon "$@"
    '';
    meta = {
      description = "Nix-native sandboxed code execution MCP (with NIX_BUILD_OPTIONS support)";
      homepage = "https://github.com/secbear/nix-sandbox-mcp";
      license = lib.licenses.mit;
      mainProgram = "nix-sandbox-mcp";
    };
  };
in
# Tree packages are stored as `pkgs.my.<dirname>` via callPackage, so expose
# the server as the package itself and the rest via passthru (mirrors
# mcp-server-devtools' withPackages pattern).
server.overrideAttrs (old: {
  passthru = old.passthru // {
    inherit daemon mkSandbox;
  };
})
