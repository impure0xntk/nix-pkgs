# JetBrains Central CLI, the CLI half of JetBrains Air. It ships a loopback
# reverse proxy (the "Air Gateway" the 2026-08 early access wrote about) that
# wires Claude Code, Codex, Gemini CLI, Junie CLI and Pi to JetBrains AI
# Platform credits. Earlier builds of the same product were named `wire`, then
# `jbcentral`, and the binary name followed those renames.
#
# The upstream archive already contains a statically linked Go binary, so this
# derivation only unpacks it.
#
# Update: bump `version`, then refresh each `hash` with
#   nix-prefetch-url --unpack <url>
{
  lib,
  prev,
  uvPkgs,
  stdenvNoCC,
  fetchzip,
  ...
}:

let
  system = stdenvNoCC.hostPlatform.system;
  version = "1.11.0";

  # Upstream path is {prog}/{version}/{prog}_{version}_linux_{arch}.tar.gz,
  # where the arch string is JetBrains' own (uname -m verbatim) and there is no
  # darwin build for this CLI.
  baseUrl = "https://jetbrains-central-cli.s3.eu-west-1.amazonaws.com/central/${version}";

  urls = {
    x86_64-linux = {
      url = "${baseUrl}/central_${version}_linux_x86_64.tar.gz";
      hash = "sha256-6lJyGgVdlgmLXQFFdHETCaXVPzjy1LCIouKClkG/e0U=";
    };
    aarch64-linux = {
      url = "${baseUrl}/central_${version}_linux_arm64.tar.gz";
      hash = "sha256-W9MaY1aO7GJEO3mPmJe6WAcfeIQ8hyYU1HS07n9+Uag=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "jetbrains-central-cli";
  inherit version;

  # fetchzip downloads and unpacks in one step, so the hashes are recursive
  # hashes of the extracted tree (nix-prefetch-url --unpack).
  src = fetchzip (
    urls.${system} or (throw "jetbrains-central-cli: unsupported system ${system}")
    // {
      # The archive is flat (`central` and `README.md` at the root), so there
      # is no single root directory to strip.
      stripRoot = false;
    }
  );

  installPhase = ''
    runHook preInstall

    install -Dm755 central $out/bin/central
    install -Dm644 README.md $out/share/doc/jetbrains-central-cli/README.md

    runHook postInstall
  '';

  meta = {
    description = "JetBrains Central CLI - Air Gateway local proxy routing AI coding agents through JetBrains AI Platform";
    longDescription = ''
      JetBrains Central CLI connects Claude Code, Codex, Gemini CLI, Junie
      CLI and Pi to JetBrains AI Platform credits. The bundled proxy runs on
      loopback and injects JetBrains authentication on the way out, so agents
      need no model-vendor API key and their own model pickers keep working.

      Login is OAuth 2.0 with PKCE against your JetBrains Account. Tokens are
      AES-256-GCM encrypted in ~/.jetbrains-central/tokens.enc with the key
      held in the system keyring, so a Secret Service provider (gnome-keyring,
      KWallet) must be reachable at runtime.

      The binary manages its own release track and self-updates, which needs a
      writable install prefix; the Nix store is read-only, so upgrading means
      bumping this derivation.
    '';
    homepage = "https://www.jetbrains.com/help/central-cli/";
    license = lib.licenses.unfree;
    mainProgram = "central";
    platforms = lib.platforms.linux;
  };
}
