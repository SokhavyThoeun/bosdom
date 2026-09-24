#!/usr/bin/env bash
# Terminal 2: runs the app on a SECOND simulator against the backend that
# ./scripts/dev.sh is already serving. Starts no backend of its own.
#
#   ./scripts/dev-app.sh                 # first booted simulator flutter picks
#   ./scripts/dev-app.sh -d "iPhone 16e" # a specific one
#
# Safe to start at the same time as dev.sh: it waits for the backend, and the
# build step is serialized against the other script by a lock.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

LAN_IP="$(detect_lan_ip)"
BASE_URL="http://$LAN_IP:$PORT"
echo "==> backend URL: $BASE_URL"

echo "==> waiting for the backend from ./scripts/dev.sh ..."
for _ in $(seq 1 120); do
  backend_is_up "$BASE_URL" && break
  sleep 1
done

if ! backend_is_up "$BASE_URL"; then
  echo "error: nothing answering on $BASE_URL after 2m." >&2
  echo "Start ./scripts/dev.sh in another terminal first." >&2
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
