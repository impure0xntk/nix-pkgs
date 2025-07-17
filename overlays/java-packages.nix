# TODO: consider to move to work package.
final: prev: rec {
  # TODO: replace to zulu25 after releasing NixOS 25.05
  jdk = prev.zulu24.overrideAttrs (old: {
    meta.priority = 10; # low
  });
  zulu = final.zulu24;

  defaultJDK = jdk;
  jdk_headless = jdk.overrideAttrs (_: {
    meta.platforms = final.lib.platforms.linux;
  });
  jre = jdk;
  jre_minimal = jdk;

  tunedJavaArgs = [
    "-XX:+UseStringDeduplication"
    "-XX:+UseZGC" # "-XX:+ZGenerational" is the default.
    # TODO: remove after NixOS 25.05, Java25 or Maven 3.9.10/4.0.0
    # https://developer.mamezou-tech.com/blogs/2025/03/30/maven-java24-warning/
    "--enable-native-access=ALL-UNNAMED" "--sun-misc-unsafe-memory-access=allow"
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

