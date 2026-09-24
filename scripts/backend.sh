#!/usr/bin/env bash
# Backend only. Detects this Mac's current LAN IP, prints the URL the
# simulators/devices should use, and runs uvicorn in the foreground.
# No Flutter, no simulators. Ctrl-C stops it.
#
#   ./scripts/backend.sh
#   PORT=9000 ./scripts/backend.sh

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

LAN_IP="$(detect_lan_ip)"
BASE_URL="http://$LAN_IP:$PORT"

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "error: something is already listening on port $PORT:" >&2
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >&2
  exit 1
fi

cat <<INFO
==> backend:  $BASE_URL
==> docs:     $BASE_URL/docs
==> local:    http://127.0.0.1:$PORT

To point an app at it:
  flutter run -d <device> --dart-define=API_BASE_URL=$BASE_URL

INFO

cd "$BACKEND_DIR"
exec uv run uvicorn bosdom_backend.main:app --host 0.0.0.0 --port "$PORT" --reload
