## Overview

`nix-pkgs` is an independent flake that provides shared packages and overlays
for nixos-reactor. It currently supports `x86_64-linux` and `aarch64-linux`.

## Structure

- `flake.nix`: Flake entry point that exposes `overlays` and `checks` for each system.
- `overlays/default.nix`: Main overlay that combines `stable`, `unstable`, and `my`.
- `overlays/java-packages.nix`: Java-related packages.
- `overlays/python-packages/`: Python environment integration using `uv2nix`, `pyproject.nix`, and `pyproject-build-systems`.
- `pkgs/top-level/`: Shared arguments passed to package definitions.
- `pkgs/tree/`: Custom package definitions. Each direct child directory is discovered automatically and built with `callPackage`.
- `tests/default.nix`: Flake check that evaluates packages from `pkgs.my`.

## Overlay Flow

`overlays/default.nix` combines packages in the following order:

1. Java packages
2. Python overlay
3. The default `bun2nix` overlay
4. Packages generated from `pkgs/tree` by `pkgs/default.nix`

The generated `my` attribute also exposes `stable` and `unstable`. The main
flake applies `nix-pkgs.overlays.${system}` as a `nixpkgs` overlay.

## Development Guidelines

- Add new overlay logic to the file responsible for that concern and compose the final overlay in `overlays/default.nix`.
- Put new packages in `pkgs/tree/<package-name>/default.nix`. Do not add a separate package list; `pkgs/default.nix` discovers direct child directories automatically.
- Follow Nixpkgs `callPackage` conventions and receive dependencies through function arguments.
- Add new packages or overlays to the checks in `tests/default.nix` and verify that they evaluate successfully.
- When adding or updating flake inputs, review the impact on this submodule and the parent repository's `flake.lock`.

## Validation

After making changes, run the following from the submodule directory:

```bash
nix flake check --impure
```

To check a specific system, use:

```bash
nix flake check --impure .#checks.x86_64-linux.pkgs-test
nix flake check --impure .#checks.aarch64-linux.pkgs-test
```

## Integration Notes

- The parent flake uses this submodule through `git+file:./submodules/nix-pkgs`.
- Changes are managed as commits inside the submodule. In the parent repository, review the submodule update and `flake.lock` diff separately.
- Do not add secrets or bypass the existing encryption and SOPS workflows.

For general workflow (issue tracking, etc.), refer to the root AGENTS.md.
