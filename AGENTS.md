# nix-pkgs - AGENTS.md

Instructions for coding agents working in this repository. Follow them exactly; they encode
invariants that are easy to break and hard to debug.

## 1. What this repository is

`nix-pkgs` is a **package-only flake**. It ships no NixOS/Home Manager modules and no library
functions — just the custom package set and the overlay that injects it into a `pkgs`.

Consumer contract (never rename or move these outputs):

| Output | Shape | Consumer |
| --- | --- | --- |
| `overlays.<system>` | a single overlay function (`final: prev: { ... }`) | `nixos-base`, `home-manager-base`, `nixos-reactor` |
| `checks.<system>.pkgs-test` | derivation | CI / `nix flake check` |

Supported systems: `x86_64-linux`, `aarch64-linux`.

The overlay result adds exactly three attributes to `pkgs`:

```nix
pkgs.my.<package-name>   # auto-discovered from pkgs/tree/*/default.nix
pkgs.stable              # nixpkgs (release-25.11) instance, unfree allowed
pkgs.unstable            # nixpkgs-unstable instance, unfree allowed
```

`pkgs.my` packages are `callPackage`-style, so they may reference any upstream nixpkgs attribute
(`buildPythonApplication`, `fetchFromGitHub`, `libnotify`, …) as a function argument.

## 2. Repository map

```
flake.nix                      # inputs, overlays.<system>, checks.<system>.pkgs-test
overlays/default.nix           # composes the final overlay: my + stable + unstable
overlays/java-packages.nix     # jdk / zulu / maven attribute set
overlays/python-packages/
  default.nix                  # buildUvPackage helper (uv2nix + pyproject.nix), pythonPackagesOverlays
  mcp/default.nix              # commented-out example of a python-only overlay entry
pkgs/default.nix               # genOverlayPackages: lists pkgs/tree/* and callPackage's each
pkgs/top-level/default.nix     # shared callPackage arguments (pkgs, prev, uvPkgs)
pkgs/top-level/all-packasges.nix  # empty placeholder, kept for the nixpkgs-parallel layout
pkgs/tree/<name>/default.nix   # ONE directory per package, auto-discovered (70 today)
pkgs/tree/<name>/*.patch       # patches, locks, assets — anything else the derivation needs
tests/default.nix              # checks.<system>.pkgs-test
```

## 3. The auto-discovery invariant (read this before adding a package)

`pkgs/default.nix` runs `lib.my.listDirs { path = ./tree; }` and then
`finalPkgs.callPackage v args` for every direct child directory. Therefore:

- **One directory per package. The directory name IS the attribute name.** `pkgs/tree/grepai/`
  becomes `pkgs.my.grepai`. Do not add a central registry file, a list, or an index.
- The loader is **not recursive**. Nested directories (`pkgs/tree/foo/bar/`) are invisible; keep
  extra files *inside* the package directory.
- Loose files directly under `pkgs/tree/` are ignored by `listDirs`, which filters on
  `v == "directory"`. Do not add `default.nix` files directly in `pkgs/tree/`.
- Renaming a directory is a **breaking API change**. `rtk grep -rn "my\.<old-name>"` across
  `../nixos-base ../home-manager-base ../machines ../home ../profiles` first.
- Attribute collisions are silent (`builtins.listToAttrs` last-wins). Two directories with the
  same name is impossible, but a package that also sets an upstream attribute name will shadow it
  inside `pkgs.my` only — that is fine, upstream `pkgs` is untouched.

## 4. Writing a new package

```nix
# pkgs/tree/<package-name>/default.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "<package-name>";
  version = "1.2.3";
  src = pkgs.fetchFromGitHub {
    owner = "OWNER";
    repo = "REPO";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # real hash, see §6
  };
  pyproject = true;
  build-system = with pkgs.python3Packages; [ hatchling ];
  dependencies = with pkgs.python3Packages; [ mcp httpx ];
  doCheck = false;
  meta = {
    description = "Short one-liner";
    homepage = "https://github.com/OWNER/REPO";
    license = lib.licenses.mit;
    mainProgram = "<cli-binary-name>";
  };
}
```

Rules:

- Module arguments are `{ pkgs, lib, ... }`. `prev` and `uvPkgs` are also available (they are
  forwarded by `pkgs/top-level/default.nix`) — `prev` is for overriding upstream packages,
  `uvPkgs` is the uv2nix-enabled package set for Python builds. `...` is mandatory.
- `callPackage` injects by argument name. A derivation that needs something not on `pkgs`/`prev`
  must get it through a new `pkgs/top-level/default.nix` entry, never by importing a sibling
  package's directory.
- For Python packages that need a modern build backend, prefer the repository helper
  `pkgs.stable`/`pkgs.unstable` python or `buildUvPackage` from `overlays/python-packages`
  instead of hand-rolling `uv2nix` calls.
- Always set `meta.mainProgram` for CLI packages — consumers use `lib.getExe`.
- Never inline a real API key, token, or password. Auth goes through environment variables
  declared in the consuming module, or a SOPS-provided file.

## 5. Overlay composition order

`overlays/default.nix` builds `final.my` in this order, and the order matters:

1. `javaPkgs` from `overlays/java-packages.nix`
2. `pythonOverlayResult` from `overlays/python-packages` (appended to `prev.pythonPackagesOverlays`)
3. `bun2nix.overlays.default`
4. `pkgsPath` (`pkgs/tree/*`) callPackage'd with `pkgs = stable // javaPkgs // python // bun2nix`

Steps 1–3 must be merged into `pkgs` **before** step 4 so that tree packages can depend on them
(that is why `pkgsWithOverlays` exists). If you add a new overlay file, wire it into
`pkgsWithOverlays` at the same place — not into `my` directly — unless it truly must not be visible
to tree packages.

## 6. Validation (run from the repository root, `x86_64-linux`)

```bash
# Fast inner loop: evaluate only, no builds (catches callPackage/type errors)
nix eval --no-write-lock-file '.#overlays.x86_64-linux' --apply 'f: builtins.attrNames (f {} {})'

# Evaluate a single package's outPath (fastest way to catch a bad hash or arg name)
nix eval --raw '.#overlays.x86_64-linux.final.my.grepai.outPath' \
  || nix build --no-link -f . '((import ./overlays) { inherit inputs; system = "x86_64-linux"; }).final'

# The repo check (currently broken, see below)
nix flake check --impure
nix flake check --impure '.#checks.x86_64-linux.pkgs-test'
nix flake check --impure '.#checks.aarch64-linux.pkgs-test'
```

**Known failure — pre-existing, not caused by your change.**
`checks.<system>.pkgs-test` fails with
`error: undefined variable 'cspell-dict-cspell-bundle'` at `tests/default.nix:5`. The overlay
derives attribute names from directory names, and the directory is `pkgs/tree/cspell-dicts/`, so the
correct reference is `pkgs.my.cspell-dicts`. Fixing the test name is a one-word change; until then,
use the `nix eval` / `nix build` commands above to validate instead of concluding your change broke
something. Also note `--impure` is required while the `nix-lib` input is resolved from the working
tree.

Hash discipline: never invent or hand-edit a `hash`. Use

```bash
nix build --impure -f . '...my.<name>'   # nix prints the correct sha256 in the error
```

and copy the *expected* value from that error into the file.

## 7. Cross-repository impact

- Consumed as `git+file:./submodules/nix-pkgs` by `nixos-reactor`, and directly by `nixos-base` and
  `home-manager-base` (both read `nix-pkgs.overlays.${system}`).
- `pkgs.my.<name>` is referenced from modules in all of those repos. Before removing or renaming a
  package, search the whole parent repo:
  ```bash
  rtk grep -rn "my\.<name>" ../../submodules/nixos-base ../../submodules/home-manager-base ../../machines ../../home ../../profiles
  ```
- `lib.my.*` helpers are consumed from `nix-lib`; if you need a new one, add it in
  `../nix-lib` first, register its test, and then use it here.
- Commit inside this submodule first, then bump the pointer in the parent repo. Review the
  submodule-pointer commit and the parent `flake.lock` change as two separate diffs.

## 8. Definition of done

A change is complete when:

1. The package lives in `pkgs/tree/<name>/default.nix` and is reachable at `pkgs.my.<name>`.
2. `nix eval` of that package's `outPath` succeeds (correct hash, correct `callPackage` args).
3. `meta` has `description`, `license`, and `mainProgram` (for CLIs).
4. The package evaluates for **both** `x86_64-linux` and `aarch64-linux` (or the deviation is
   explicitly documented in the commit message).
5. `tests/default.nix` is either still failing only on the known `cspell-dicts` name, or updated.
6. No secrets, no license-incompatible code copied in, no unrelated `nixpkgs` pinning changes.
