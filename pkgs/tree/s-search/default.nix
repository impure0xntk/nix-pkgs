{ pkgs, ... }:
pkgs.buildGoModule rec {
  pname = "s-search";
  version = "0.7.3";
  src =  pkgs.fetchFromGitHub {
    owner = "zquestz";
    repo = "s";
    rev = "v${version}";
    hash = "sha256-g+Gz16U5rP3v+RbutDUh5+1YdTDe+ROFEnNAlNZX1fw=";
  };
  vendorHash = "sha256-0E/9fONanSxb2Tv5wKIpf1J/A6Hdge23xy3r6pFyV9E=";

  meta = with pkgs.lib; {
    homepage = "https://github.com/zquestz/s";
    description = "Open a web search in your terminal.";
    license = with licenses; [mit];
    platforms = platforms.linux;
  };
}
