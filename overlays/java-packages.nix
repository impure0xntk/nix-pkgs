# TODO: consider to move to work package.
final: prev: rec {
  tunedJavaArgs = [
    "-XX:+UseStringDeduplication"
    "-XX:+UseZGC" # "-XX:+ZGenerational" is the default.
    "-XX:+UseLargePages"
  ];
  tunedJavaToolArgs = tunedJavaArgs ++ [ ## unofficial: https://dev.to/nfrankel/faster-maven-builds-17dn etc...;
    "-XX:-TieredCompilation" "-XX:TieredStopAtLevel=1"
  ];

  # https://github.com/NixOS/nixpkgs/issues/375254
  jetbrains = prev.jetbrains // {
    gateway = let
      unwrapped = prev.jetbrains.gateway;
    in prev.buildFHSEnv {
      name = "gateway";
      inherit (unwrapped) version;

      runScript = prev.writeScript "gateway-wrapper" ''
        unset JETBRAINS_CLIENT_JDK
        exec ${unwrapped}/bin/gateway "$@"
      '';

      meta = unwrapped.meta;

      passthru = {
        inherit unwrapped;
      };
    };
  };
}

