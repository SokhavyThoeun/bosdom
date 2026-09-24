#!/usr/bin/env bash
# Terminal 1: starts the backend on this Mac's current LAN IP, then runs the
# app on ONE simulator with that IP baked in.
#
#   ./scripts/dev.sh                 # first booted simulator
#   ./scripts/dev.sh -d "iPhone 15"  # a specific one
#
# For a second simulator, open another terminal and use ./scripts/dev-app.sh.
# Ctrl-C stops the app and the backend.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

LAN_IP="$(detect_lan_ip)"
BASE_URL="http://$LAN_IP:$PORT"
echo "==> backend URL: $BASE_URL"

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "error: something is already listening on port $PORT:" >&2
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >&2
  echo "If that is another dev.sh, use ./scripts/dev-app.sh here instead." >&2
  exit 1
fi

cd "$BACKEND_DIR"
uv run uvicorn bosdom_backend.main:app --host 0.0.0.0 --port "$PORT" --reload &
BACKEND_PID=$!

cleanup() {
  echo
  echo "==> stopping backend (pid $BACKEND_PID)"
  kill "$BACKEND_PID" 2>/dev/null || true
  wait "$BACKEND_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "==> waiting for backend to come up..."
for _ in $(seq 1 40); do
  backend_is_up "$BASE_URL" && break
  if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "error: backend died on startup — see the uvicorn output above." >&2
    exit 1
  fi
  sleep 0.5
done

if ! backend_is_up "$BASE_URL"; then
  echo "error: backend never answered on $BASE_URL after 20s." >&2
  exit 1
fi
echo "==> backend is up at $BASE_URL"

DART_DEFINE="API_BASE_URL=$BASE_URL"
prebuild_locked "$DART_DEFINE"

FLUTTER_ARGS=("$@")
[ "$#" -eq 0 ] && FLUTTER_ARGS=()

cd "$APP_DIR"
echo "==> flutter run ${FLUTTER_ARGS[*]} --dart-define=$DART_DEFINE"
flutter run "${FLUTTER_ARGS[@]}" --dart-define="$DART_DEFINE"
