# textlint-client

CLI client for textlint-server.

## Overview

This client communicates with textlint-server to lint documents and returns output in the same format as the textlint本身.

## Usage

### Basic Usage

```bash
# With textlint-server running
textlint-client <file>
```

### Specifying a Config File

```bash
textlint-client <file> <config-file>
```

## Examples

### Linting with Default Config

```bash
textlint-client README.md
```

### Specifying a Custom Config File

```bash
textlint-client README.md .textlintrc.json
```

## Prerequisites

1. `textlint-server` must be running (default: `http://localhost:8080/api/textlint`)

```bash
# Start textlint-server
./result/bin/textlint-server
```

1. `jq` command is required (included in the package)

## How It Works

1. Read the specified file
2. Send HTTP POST request to textlint-server
3. Append `filePath` field to the response from textlint-server (array format)
4. Output in the same format as textlint itself

## Output Format

```json
[
  {
    "type": "lint",
    "ruleId": "textlint-rule-sentence-length",
    "message": "Line 1 sentence length(68) exceeds the maximum sentence length of 50.",
    "index": 0,
    "line": 1,
    "column": 1,
    "range": [0, 68],
    "loc": {
      "start": { "line": 1, "column": 1 },
      "end": { "line": 1, "column": 69 }
    },
    "severity": 2,
    "filePath": "/path/to/your/file.md"
  }
]
```

This is identical to the format output by textlint with `--format json`.

## Architecture

```text
textlint-client  -->  curl (HTTP POST)  -->  textlint-server  -->  spawn(textlint-all)
                   ↑                                       ↓
                   |                                   textlint-all binary
                   |                                       ↓
                   |                                   Apply all rules
                   |                                       ↓
                   |                                   Return results in JSON
                   |                                       ↓
                   └──── Add filePath to results ──────────┘
```

## Build

```bash
cd submodules/nix-pkgs/pkgs/tree/textlint-client
nix-build default.nix
```

## Related Files

- `default.nix` - textlint-client definition
- `../textlint-server/` - textlint-server implementation
- `../textlint-all/` - Package containing all textlint rules
