{
  pkgs,
  lib,
  nix-update-script,
  ...
}:
let
  # The rmcp 3.x re-pin below pulls crates whose MSRV is 1.88, which the
  # pinned `stable` toolchain (25.11, rustc 1.86) does not satisfy, so the
  # build has to come from the newer `unstable` toolchain.
  rustPlatform = pkgs.unstable.rustPlatform;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcp-compressor";
  version = "0.32.1";

  src = pkgs.fetchFromGitHub {
    owner = "atlassian-labs";
    repo = "mcp-compressor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jOcbbstGaH5E/XFGEYbMHe/sNBluf4NMdEmgsB9jmVo=";
  };

  # For coding agents that speak the current MCP model (e.g. Goose):
  # rmcp 1.8.0 is the last 1.x and predates the MCP 2025-11-25 model
  # alignment that landed in rmcp 2.0.0 (Content -> ContentBlock,
  # Annotated<T>/Meta -> MetaObject, call_tool/read_resource/get_prompt now
  # return *Response enums, StreamableHttpClient::get_stream session_id is
  # optional, OAuth start_authorization takes an AuthorizationRequest).
  # Upstream still requires rmcp ^1.7.0, so the patch raises the requirement
  # to ^3.2.0, re-resolves the lock (rmcp, rmcp-macros, darling, process-wrap,
  # sse-stream, plus new base64 0.23 and syn 3) and rewrites the call sites.
  # TODO: remove after update
  cargoPatches = [ ./rmcp-3.2.0.patch ];
  cargoHash = "sha256-/zc7c1zyA1FFNKvoNra/r92ygX7UklV8IwMcn074dbk=";

  # The workspace also ships Python (pyo3) and Node (napi) bindings.
  # Only the CLI binary is packaged here; building every member would
  # require a Python interpreter and a Node toolchain for no benefit.
  cargoBuildFlags = [
    "-p"
    "mcp-compressor"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP proxy that compresses tool schemas and generates CLI, Python and TypeScript clients";
    homepage = "https://github.com/atlassian-labs/mcp-compressor";
    changelog = "https://github.com/atlassian-labs/mcp-compressor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    mainProgram = "mcp-compressor";
    platforms = lib.platforms.unix;
  };
})
