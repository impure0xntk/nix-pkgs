{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation (finalAttrs: rec {
  pname = "NanoProxy";
  version = "1a67f28fb2aaf015e3fba234dd36ced43353a999";
  src = pkgs.fetchFromGitHub {
    owner = "nanogpt-community";
    repo = pname;
    rev = version;
    hash = "sha256-G67GwGIkUSvO9XtPwAVrY7s3N4FwLYyIRJ2YPvUMvME=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
  ];

  patches = [(pkgs.writeText "404-html-handling" ''
diff --git a/server.js b/server.js
index 471ea58..23bd199 100644
--- a/server.js
+++ b/server.js
@@ -506,2 +506,25 @@ async function proxyRequest(req, res) {

+  // For 404 error handling with HTML
+  if (contentType.includes("text/html") && !req.url.includes("/health")) {
+    const htmlBody = await upstreamResponse.text();
+    console.error("[NanoProxy] Received HTML instead of JSON from upstream:");
+    console.error(`Status: ''${upstreamResponse.status}`);
+    console.error(htmlBody.substring(0, 500));
+
+    const errorPayload = {
+      error: {
+        code: upstreamResponse.status === 404 ? "model_not_found" : "upstream_html_response",
+        message: upstreamResponse.status === 404
+          ? "Model not found or endpoint does not exist. Check model ID."
+          : "Upstream returned HTML instead of JSON. Possible Cloudflare challenge or server error.",
+        upstream_status: upstreamResponse.status
+      }
+    };
+    const buf = Buffer.from(JSON.stringify(errorPayload), "utf8");
+    res.writeHead(upstreamResponse.status, { "content-type": "application/json; charset=utf-8", "content-length": String(buf.length) });
+    res.end(buf);
+    log(`--- HTML ERROR RESPONSE (status ''${upstreamResponse.status}) ---\n`);
+    return;
+  }
+
   const rawBuffer = Buffer.from(await upstreamResponse.arrayBuffer());
@@ -510,3 +533,4 @@ async function proxyRequest(req, res) {
   res.end(rawBuffer);
-  log(`--- PASSTHROUGH (status ''${upstreamResponse.status}) ---\n`);
+  log(`--- PASSTHROUGH (status ''${upstreamResponse.status}) ---\
+`);
 }

    '')
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r src $out/
    cp -r server.js $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/nanoproxy
    echo "export NODE_PATH=$out/src; ${pkgs.nodejs}/bin/node $out/server.js \"\$@\"" >> $out/bin/nanoproxy
    chmod +x $out/bin/nanoproxy

    runHook postInstall
  '';

  meta = {
    description = "A local proxy for OpenCode and similar OpenAI-compatible coding clients that works around NanoGPT’s often unreliable native tool calling. Instead of relying on NanoGPT to return proper tool calls directly, it sends a stricter text-based tool format upstream and converts that back into normal OpenAI-style tool calls for the client.";
    homepage = "https://github.com/nanogpt-community/NanoProxy";
    license = lib.licenses.mit;
    mainProgram = "nanoproxy";
  };
})