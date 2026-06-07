{ pkgs, lib, ... }:
pkgs.unstable.rustPlatform.buildRustPackage rec {
  pname = "headroom-ai";
  version = "0.23.0";

  src = pkgs.fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-4pQUSi8dU85tm5WY8Z/ZEN8O/ccGDDVIC3SnNBvUZTY=";
  };

  cargoHash = "sha256-WQBvil0bsS6/Z6b+uRauwOQq4VZ57VwAoghcyFdVgLE=";

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
