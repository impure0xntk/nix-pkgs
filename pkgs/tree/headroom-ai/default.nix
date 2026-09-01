{ pkgs, lib, ... }:
pkgs.unstable.rustPlatform.buildRustPackage rec {
  pname = "headroom-ai";
  version = "0.37.0";

  src = pkgs.fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-89Tkzx56QIZWfNWLaiPdMynZGOLPr5EAP5RnLSgvBsA=";
  };

  cargoHash = "sha256-iEvap6uLsAqCSv+l/S7K7osxL+yV7Y8pE6Dhaqt2AIA=";

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
