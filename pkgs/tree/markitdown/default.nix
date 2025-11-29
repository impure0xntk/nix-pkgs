# In NixOS 25.11, this is not used: markitdown in nixpkgs is now latest version.
# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
let
  version = "0.1.2";
  srcRoot = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "markitdown";
    rev = "v${version}";
    hash = "sha256-7T5cuFBivazKlUk3OKXKKU3YazRAfGRt9O+gCYX3ciQ=";
  };
  basicDeps = with pkgs.python3Packages; [
    # required
    beautifulsoup4
    requests
    markdownify
    magika
    charset-normalizer
    defusedxml

    # office file (pptx, docx, xls{,x}, pdf)
    python-pptx
    mammoth
    pandas
    openpyxl
    xlrd
    lxml
    pdfminer-six
  ];
  optionalDeps = with pkgs.python3Packages; rec {
    outlook = [ olefile ];
    audio = [
      pydub
      speechrecognition
    ];
    youtube = [ youtube-transcript-api ];
    # azure = [ azure-ai-documentintelligence azure-identity ];
  };

  createPackage =
    deps:
    pkgs.python3Packages.buildPythonApplication {
      pname = "markitdown";
      inherit version;

      src = "${srcRoot}/packages/markitdown";

      pyproject = true;

      build-system = with pkgs.python3Packages; [
        hatchling
      ];

      dependencies = deps;

      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail 'dynamic = ["version"]' \
            'version = "${version}"'
      '';

      # Disable tests for now - can enable once we know the test structure
      doCheck = false;

      meta = {
        description = "Python tool for converting files and office documents to Markdown.";
        homepage = "https://github.com/microsoft/markitdown";
        license = lib.licenses.mit;
        mainProgram = "markitdown";
      };
    };
in
(createPackage basicDeps).overridePythonAttrs (self: {
  passthru = self.passthru // {
    inherit srcRoot;

    outlook = createPackage (basicDeps ++ optionalDeps.outlook);
    audio = createPackage (basicDeps ++ optionalDeps.audio);
    youtube = createPackage (basicDeps ++ optionalDeps.youtube);
    # TODO: not work: needs too much RAM
    all = createPackage (basicDeps ++ (builtins.concatLists (builtins.attrValues optionalDeps)));
  };
})
