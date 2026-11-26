#!/usr/bin/env bash
set -Eeuo pipefail

# Usage:
#   oci-bastion-proxy \
#     BASTION_OCID INSTANCE_OCID USER PRIVATE_KEY PUBLIC_KEY HOST PORT [OCI_PROFILE] [-- SSH_ARGS...]

if [[ $# -lt 7 ]]; then
  echo "Usage: $0 BASTION_OCID INSTANCE_OCID USER PRIVATE_KEY PUBLIC_KEY HOST PORT [OCI_PROFILE] [-- SSH_ARGS...]" >&2
  exit 2
fi

BASTION_ID="$1"
INSTANCE_ID="$2"
TARGET_USER="$3"
PRIVATE_KEY="$(realpath -e "$4")"
PUBLIC_KEY="$(realpath -e "$5")"
TARGET_HOST="$6"
TARGET_PORT="$7"
OCI_PROFILE="${8:-${OCI_PROFILE:-}}"
shift "$(( $# < 8 ? $# : 8 ))"
if [[ "${1:-}" == "--" ]]; then
  shift
fi

SESSION_TTL="${OCI_BASTION_SESSION_TTL:-1800}"
POLL_INTERVAL="${OCI_BASTION_POLL_INTERVAL:-3}"
MAX_WAIT="${OCI_BASTION_MAX_WAIT:-300}"

# OCI_BIN overrides the CLI so a different build/version can be injected.
OCI=( "${OCI_BIN:-oci}" )
# OCI_ARGS carries extra global flags (e.g. --auth instance_principal).
if [[ -n "${OCI_ARGS:-}" ]]; then
  # shellcheck disable=SC2206 # intentional word splitting
  OCI+=( ${OCI_ARGS} )
fi
if [[ -n "$OCI_PROFILE" ]]; then
  OCI+=( --profile "$OCI_PROFILE" )
fi

for cmd in realpath grep ssh; do
  command -v "$cmd" >/dev/null || {
    echo "Missing command: $cmd" >&2
    exit 127
  }
done

command -v "${OCI[0]}" >/dev/null || {
  echo "Missing OCI CLI: ${OCI[0]} (set OCI_BIN to override)" >&2
  exit 127
}

[[ -r "$PRIVATE_KEY" ]] || {
  echo "Private key not readable: $PRIVATE_KEY" >&2
  exit 1
}

[[ -r "$PUBLIC_KEY" ]] || {
  echo "Public key not readable: $PUBLIC_KEY" >&2
  exit 1
}

SESSION_ID=""

cleanup() {
  local rc=$?
  trap - EXIT

  if [[ -n "$SESSION_ID" ]]; then
    echo "Deleting Bastion session: $SESSION_ID" >&2

    "${OCI[@]}" bastion session delete \
      --session-id "$SESSION_ID" \
      --force \
      --wait-for-state SUCCEEDED \
      --max-wait-seconds 120 \
      >/dev/null 2>&1 || {
        echo "Warning: session deletion failed; TTL will expire it." >&2
      }
  fi

  exit "$rc"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo "Creating OCI Bastion Managed SSH session..." >&2

SESSION_ID=$(
  "${OCI[@]}" bastion session create-managed-ssh \
    --bastion-id "$BASTION_ID" \
    --target-resource-id "$INSTANCE_ID" \
    --target-os-username "$TARGET_USER" \
    --target-port "$TARGET_PORT" \
    --ssh-public-key-file "$PUBLIC_KEY" \
    --session-ttl "$SESSION_TTL" \
    --display-name "ssh-${HOSTNAME:-$(hostname)}-$$" \
    --query 'data.id' \
    --raw-output
)

if [[ -z "$SESSION_ID" || "$SESSION_ID" == "None" ]]; then
  echo "Failed to create Bastion session" >&2
  exit 1
fi

echo "Session ID: $SESSION_ID" >&2

elapsed=0
state=""

while (( elapsed < MAX_WAIT )); do
  state=$(
    "${OCI[@]}" bastion session get \
      --session-id "$SESSION_ID" \
      --query 'data."lifecycle-state"' \
      --raw-output
  )

  case "$state" in
    ACTIVE)
      break
      ;;
    FAILED | DELETED | DELETING)
      echo "Bastion session entered unexpected state: $state" >&2
      exit 1
      ;;
  esac

  sleep "$POLL_INTERVAL"
  (( elapsed += POLL_INTERVAL ))
done

if [[ "$state" != "ACTIVE" ]]; then
  echo "Timed out waiting for Bastion session: ${state:-unknown}" >&2
  exit 1
fi

ssh_command=$(
  "${OCI[@]}" bastion session get \
    --session-id "$SESSION_ID" \
    --query 'data."ssh-metadata".command' \
    --raw-output
)

BASTION_HOST=$(
  printf '%s\n' "$ssh_command" |
    grep -oE 'host\.bastion\.[A-Za-z0-9.-]+' |
    head -n 1
)

if [[ -z "$BASTION_HOST" ]]; then
  echo "Could not determine Bastion endpoint from SSH metadata" >&2
  exit 1
fi

echo "Connecting through $BASTION_HOST" >&2

exec ssh \
  -i "$PRIVATE_KEY" \
  -o IdentitiesOnly=yes \
  -o BatchMode=yes \
  -W "${TARGET_HOST}:${TARGET_PORT}" \
  -p 22 \
  "$@" \
  "${SESSION_ID}@${BASTION_HOST}"

