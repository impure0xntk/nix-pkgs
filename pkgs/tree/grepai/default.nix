{ pkgs, lib, fetchFromGitHub, nix-update-script, ... }:
pkgs.unstable.buildGoModule (finalAttrs: {
  pname = "grepai";
  version = "0.37.0";
  __structuredAttrs = true;
  src = fetchFromGitHub {
    owner = "yoanbernabeu";
    repo = "grepai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VnwnAQrgp47YcmC+1xwf/NSDxB1uR14e8cF4UA+fl84=";
  };
  vendorHash = "sha256-WFrXPfBk2zo+uYPFmzns1p3r4IbeWgKuUMmEU/DbKqA=";
  nativeBuildInputs = [ pkgs.git pkgs.nodejs ];
  ldflags = [ "-s" ];
  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Semantic code search CLI tool - grep for the AI era";
    homepage = "https://github.com/yoanbernabeu/grepai";
    changelog = "https://github.com/yoanbernabeu/grepai/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "grepai";
    platforms = lib.platforms.linux;
  };
})