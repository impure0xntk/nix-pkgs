# TODO: remove after NixOS 25.11 .
# This is workaround of missing litellm.
# 2025/06/18
# From: https://raw.githubusercontent.com/NixOS/nixpkgs/abd741e3d9b28e4d1b5cb01f7dd17ca286660145/pkgs/by-name/sh/shell-gpt/package.nix
{
  lib,
  fetchFromGitHub,
  python3,
  ...
}:
python3.pkgs.buildPythonApplication rec {
  pname = "shell-gpt";
  version = "1.4.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "TheR1D";
    repo = "shell_gpt";
    tag = version;
    hash = "sha256-e0zKlbt508psiV1ryuE/JV0rWM/XZDhMChqReGHefig=";
  };

  pythonRelaxDeps = [
    "requests"
    "rich"
    "distro"
    "typer"
    "instructor"
    "jinja2"
  ];

  build-system = with python3.pkgs; [ hatchling ];

  propagatedBuildInputs = with python3.pkgs; [
    jinja2
    requests
    click
    distro
    instructor
    litellm
    openai
    rich
    typer
  ];

  buildInputs = with python3.pkgs; [
    litellm
  ];

  # Tests want to read the OpenAI API key from stdin
  doCheck = false;

  meta = with lib; {
    description = "Access ChatGPT from your terminal";
    homepage = "https://github.com/TheR1D/shell_gpt";
    changelog = "https://github.com/TheR1D/shell_gpt/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ SohamG ];
    mainProgram = "sgpt";
  };
}