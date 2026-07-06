{ pkgs, lib, ... }:
pkgs.unstable.rustPlatform.buildRustPackage rec {
  pname = "headroom-ai";
  version = "0.30.0";

  src = pkgs.fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-BxZq6UzmLae7eNrE7iUuunM3hRM4E41i4j6LsKFyFdk=";
  };

  cargoHash = "sha256-cXvIbFaX008BvYLBWVvrj5pnF8CM8qOdbdg0kKAZ9uY=";

  buildInputs = with pkgs.unstable; [
    onnxruntime
  ];
  env = {
    ORT_STRATEGY = "system";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_LIB_LOCATION = "${pkgs.unstable.onnxruntime}";
    ORT_INCLUDE_LOCATION = "${pkgs.unstable.onnxruntime.dev}/include";
  };

  meta = with lib; {
    description = "Context optimization layer for LLM applications";
    homepage = "https://github.com/chopratejas/headroom";
    license = licenses.asl20;
    mainProgram = "headroom";
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
