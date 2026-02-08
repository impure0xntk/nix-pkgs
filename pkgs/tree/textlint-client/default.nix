{
  pkgs ? import <nixpkgs> {},
  ...
}:

pkgs.writeShellApplication {
  name = "textlint-client";
  runtimeInputs = [ pkgs.curl pkgs.jq ];
  text = ''
  SERVER_URL="http://localhost:8080/api/textlint"
  FILE="$1"

  if [ -z "$FILE" ]; then
    echo "Usage: textlint-client <file> [config-file]"
    echo ""
    echo "Arguments:"
    echo "  file         File to lint"
    echo "  config-file  Optional textlintrc json file"
    echo ""
    echo "Examples:"
    echo "  textlint-client README.md"
    echo "  textlint-client README.md .textlintrc.json"
    exit 1
  fi

  CONFIG_FILE="$2"
  CONFIG_JSON=""

  # Load JSON if config-file is specified
  if [ -n "$CONFIG_FILE" ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
      echo "Error: Config file not found: $CONFIG_FILE" >&2
      exit 1
    fi
    CONFIG_JSON=$(cat "$CONFIG_FILE")
  fi

  # Read file content
  if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE" >&2
    exit 1
  fi

  TEXT=$(cat "$FILE")

  # Create JSON payload
  if [ -n "$CONFIG_JSON" ]; then
    PAYLOAD=$(jq -n --arg text "$TEXT" --argjson config "$CONFIG_JSON" '{text: $text, config: $config}')
  else
    PAYLOAD=$(jq -n --arg text "$TEXT" '{text: $text}')
  fi

  # Send request to textlint-server
  RESPONSE=$(curl -s -X POST "$SERVER_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

  # Get JSON response and add filePath to match standard textlint output format
  echo "$RESPONSE" | jq --arg filePath "$FILE" '.[] + {filePath: $filePath}' || echo "$RESPONSE"
'';
}
