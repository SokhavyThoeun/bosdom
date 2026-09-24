#!/usr/bin/env bash
# One command for the whole dev setup:
#   - boots both simulators
#   - starts the backend on this Mac's current LAN IP
#   - builds once (so the two runs cannot race over Flutter.framework)
#   - opens a second Terminal window running the 2nd simulator
#   - runs the 1st simulator here, in this window
#
# Both windows get full hot reload (press r / R in either).
#
#   ./scripts/dev-all.sh
#   SIM1="iPhone 17" SIM2="iPhone 15" ./scripts/dev-all.sh
#
# Ctrl-C here stops the backend and this sim's app. The second window is its
# own session — Ctrl-C there too, or just close it.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

SIM1="${SIM1:-iPhone 15}"
SIM2="${SIM2:-iPhone 16e}"

SIM1_UDID="$(resolve_sim "$SIM1")"
SIM2_UDID="$(resolve_sim "$SIM2")"

if [ -z "$SIM1_UDID" ] || [ -z "$SIM2_UDID" ]; then
  echo "error: could not resolve both simulators." >&2
  [ -z "$SIM1_UDID" ] && echo "  SIM1 not found: $SIM1" >&2
  [ -z "$SIM2_UDID" ] && echo "  SIM2 not found: $SIM2" >&2
  echo "Available:" >&2
  xcrun simctl list devices available | grep -iE 'iphone|ipad' >&2
  exit 1
fi

echo "==> sim 1: $SIM1 ($SIM1_UDID)"
echo "==> sim 2: $SIM2 ($SIM2_UDID)"

boot_sim "$SIM1_UDID"
boot_sim "$SIM2_UDID"
open -a Simulator

# --- backend ------------------------------------------------------------------
LAN_IP="$(detect_lan_ip)"
BASE_URL="http://$LAN_IP:$PORT"
echo "==> backend URL: $BASE_URL"

BACKEND_PID=""
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "==> port $PORT already serving; reusing it (not starting another)"
else
  ( cd "$BACKEND_DIR" && uv run uvicorn bosdom_backend.main:app \
      --host 0.0.0.0 --port "$PORT" --reload ) &
  BACKEND_PID=$!
fi

cleanup() {
  if [ -n "$BACKEND_PID" ]; then
    echo
    echo "==> stopping backend (pid $BACKEND_PID)"
    kill "$BACKEND_PID" 2>/dev/null || true
    wait "$BACKEND_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "==> waiting for backend..."
for _ in $(seq 1 40); do
  backend_is_up "$BASE_URL" && break
  if [ -n "$BACKEND_PID" ] && ! kill -0 "$BACKEND_PID" 2>/dev/null; then
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

# Build once here so the second window's build is a no-op and the two Xcode
# builds cannot collide on build/ios/Debug-iphonesimulator/Flutter.framework.
prebuild_locked "$DART_DEFINE"

# --- second window ------------------------------------------------------------
SECOND_CMD="cd '$ROOT' && ./scripts/dev-app.sh -d '$SIM2_UDID'"
echo "==> opening a second Terminal window for $SIM2"
osascript >/dev/null <<OSA
tell application "Terminal"
  do script "$SECOND_CMD"
  activate
end tell
OSA

# --- this window --------------------------------------------------------------
cd "$APP_DIR"
echo "==> flutter run -d $SIM1 --dart-define=$DART_DEFINE"
flutter run -d "$SIM1_UDID" --dart-define="$DART_DEFINE"
