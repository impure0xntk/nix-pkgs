{
  pkgs,
  lib,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

pkgs.unstable.buildGoModule (finalAttrs: {
  pname = "ghqr";
  version = "0.4.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "ghqr";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-TJ2PoWidUVcNC1RaZJVXXVqstc0nlgurqAxgvbQXSCc=";
  };

  vendorHash = "sha256-la/yXEZzAIt9l0q0P7+N8yCW0BQie9sLmAhLFK1qyGE=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GitHub Quick Review: Evaluate your enterprise and organizations against GitHub best practices";
    homepage = "https://github.com/microsoft/ghqr";
    changelog = "https://github.com/microsoft/ghqr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ghqr";
  };
})
