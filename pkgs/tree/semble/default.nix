# Hybrid (BM25 + static embedding) code search built for coding agents.
# Exposes the same engine twice: `semble <query>` on the CLI and an MCP server
# when invoked without a subcommand, which is what the home manager harness
# registers as a backend.
#
# All four distributions are published as wheels, so nothing here compiles.
# The dependency closure is what is missing from nixpkgs: model2vec,
# vicinity and semble-grammars are all unpatched upstream, so they are built
# against the same `pkgs.stable.python3Packages` set the application resolves
# from, keeping the closure inside one interpreter.
{
  pkgs,
  lib,
  ...
}:
let
  # `pkgs.stable` rather than the default python: the whole closure below is
  # pinned to one interpreter this way instead of dragging the consumer's in.
  py = pkgs.stable.python3Packages;

  # nixpkgs still ships 0.12.1, whose from_lines() has no `backend` keyword;
  # semble calls GitIgnoreSpec.from_lines(..., backend="simple") and dies with a
  # TypeError while walking a tree. 1.x adds the backend selection, and the
  # "simple" backend it names is the pure-python one, so nothing extra is pulled
  # in (re2 and hyperscan stay optional and absent).
  pathspec = py.buildPythonPackage {
    pname = "pathspec";
    version = "1.1.1";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/f1/d9/7fb5aa316bc299258e68c73ba3bddbc499654a07f151cba08f6153988714/pathspec-1.1.1-py3-none-any.whl";
      hash = "sha256-oAzmQvV3v39HOTIxgFYhK8T4v99TEox4u9WvC5sgsYk=";
    };
    doCheck = false;
  };

  # Static embedding runtime. 0.9.0 imports huggingface_hub from
  # model2vec.persistence.hf without declaring it in Requires-Dist, so it is
  # added here: without it the first model load dies on ImportError.
  model2vec = py.buildPythonPackage {
    pname = "model2vec";
    version = "0.9.0";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/af/ea/80246465cafa36a6c8c8ac767778423940e5b826fa57c10ebd957b570c1c/model2vec-0.9.0-py3-none-any.whl";
      hash = "sha256-i88yWNVmhnhznBMialYtOe6uuPysmxQrxKzu+IANW50=";
    };
    dependencies = [
      py.huggingface-hub
      py.jinja2
      py.joblib
      py.numpy
      py.safetensors
      py.tokenizers
      py.tqdm
    ];
    doCheck = false;
  };

  # Dense index storage backend.
  vicinity = py.buildPythonPackage {
    pname = "vicinity";
    version = "0.4.6";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/9c/6f/5ed3e84eb7ee82032a8894f54645a6cb5ffcceeb83b78133cb21b40e711f/vicinity-0.4.6-py3-none-any.whl";
      hash = "sha256-hhKkm/QZC8y1i7OgwNNMMWZTxv/8ASIYJwMuY42ldqY=";
    };
    dependencies = [
      py.numpy
      py.orjson
      py.tqdm
    ];
    doCheck = false;
  };

  # Prebuilt tree-sitter grammars for 19 languages. Published as platform
  # wheels only: there is no sdist to build from and no nixpkgs grammar set to
  # point at instead, so the URL and hash are per-architecture.
  sembleGrammars = py.buildPythonPackage {
    pname = "semble-grammars";
    version = "0.1.2";
    format = "wheel";
    src =
      if pkgs.stdenv.hostPlatform.isAarch64 then
        pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/32/e2/bec01f956cd7aa52505a57954f3259febd00092715eac6f0ea1fff6058e0/semble_grammars-0.1.2-py3-none-manylinux2014_aarch64.whl";
          hash = "sha256-8k9joE5Wny3iiq85FmyN3djilqoDkKyBbfatG9gU478=";
        }
      else
        pkgs.fetchurl {
          url = "https://files.pythonhosted.org/packages/9d/d9/e93eb269ccd2494cf4b5ac2f201b5badb959800bf21a2ae700d6d7f6418a/semble_grammars-0.1.2-py3-none-manylinux2014_x86_64.whl";
          hash = "sha256-wEBZXKThF5aaNJgH3OBcGlHbs2joDegLAFU5/YbvnAc=";
        };
    dependencies = [ py."tree-sitter" ];
    doCheck = false;
  };
in
py.buildPythonApplication {
  pname = "semble";
  version = "0.6.1";
  format = "wheel";
  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/de/62/0287f43a8d6012fa9a4406d75bc6a6a1ee3d190732e8d7d9760122f77bc2/semble-0.6.1-py3-none-any.whl";
    hash = "sha256-/qls9g2TVVlm1X8mYEuO+TW/P4dnV1aM7J/mVd1lElY=";
  };
  dependencies = [
    model2vec
    vicinity
    sembleGrammars
    py.numpy
    py.orjson
    pathspec
    py.questionary
    py."tree-sitter"
    py.tqdm
    # The "mcp" extra. Selecting it is what turns the bare `semble` command
    # into an MCP server instead of a CLI that prints its help.
    py.mcp
  ];
  doCheck = false;

  meta = {
    description = "Fast and accurate hybrid code search for coding agents (MCP server and CLI)";
    homepage = "https://github.com/MinishLab/semble";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "semble";
  };
}
