{ pkgs,
  jdk,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "byteman";
  version = "4.0.22";
  src = pkgs.fetchzip {
    url = "https://downloads.jboss.org/byteman/${version}/byteman-download-${version}-bin.zip";
    hash = "sha256-mnsYhuy6G2aSdtTCzlhBD/BrHPNnH2jQBLsVaxng9FQ=";
  };
  buildInputs = [ jdk ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  dontPatchShebangs = true;
  installPhase = ''
    mkdir -p $out/{bin,lib,sample}
    cp -r $src/bin $out
    cp -r $src/lib $out
    cp -r $src/sample $out

    chmod -R +x $out/bin
    for executable in $out/bin/*; do
      wrapProgram "$executable" \
        --set PATH ${jdk}/bin:$PATH \
        --set JAVA_HOME ${jdk} \
        --set BYTEMAN_HOME $out
    done
    # requires jdk8 (not jre, and < jdk9)
    test -f ${jdk}/lib/tools.jar
  '';

  # TODO: check license.
  meta = with pkgs.lib; {
    homepage = "https://byteman.jboss.org/index.html";
    description = "Simplify Java tracing, monitoring and testing with Byteman";
    # license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}

# class TestClass {
#   public void println() {
#     System.out.println("hello");
#   }
# }
#
# class TestClassStatic {
#   public static void println() {
#     System.out.println("hello static");
#   }
# }
#
# class Main {
#   public static void main(String[] args) {
#     TestClass test = new TestClass();
#     TestClassStatic testStatic = new TestClassStatic();
#     while (true) {
#       test.println();
#       testStatic.println();
#       try {
#         Thread.sleep(10000);
#       } catch (InterruptedException e) {
#         // do nothing
#       }
#     }
#   }
# }

# RULE hello byteman
# CLASS TestClass
# METHOD println
# AT ENTRY
# IF true
# DO traceln("Hello Byteman!!")
# ENDRULE
#
# RULE hello static byteman
# CLASS TestClassStatic
# METHOD println
# AT EXIT
# IF true
# DO traceln("hello test static Byteman!!")
# ENDRULE
#
# RULE invoke
# CLASS Main
# METHOD main
# AT READ $test
# IF true
# DO traceln("invoke before test.println")
# ENDRULE


