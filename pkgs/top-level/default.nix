attrs@{
  pkgs,
  prev,
  uvPkgs,
  ...
}:
{
  inherit prev uvPkgs; # prev creates override packages; uvPkgs includes uv2nix helpers.
}
