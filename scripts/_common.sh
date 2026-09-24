#!/usr/bin/env bash
# Shared helpers for the dev scripts. Not meant to be run directly.

PORT="${PORT:-8000}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT/bosdom-backend"
APP_DIR="$ROOT/bosdom"
BUILD_LOCK="$APP_DIR/build/.dev-build.lock"

# Echoes the LAN IP the simulators/devices can reach; exits if there is none.
detect_lan_ip() {
  local iface ip
  for iface in $(route -n get default 2>/dev/null | awk '/interface:/{print $2}') en0 en1 en2; do
    ip="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
    if [ -n "$ip" ]; then echo "$ip"; return 0; fi
  done
  echo "error: no LAN IP found — are you connected to Wi-Fi?" >&2
  return 1
}

backend_is_up() {
  curl -fs --max-time 2 -o /dev/null "$1/docs" 2>/dev/null
}

# Two Flutter builds running at once write the same
# build/ios/Debug-iphonesimulator/Flutter.framework/Flutter and race over it
# ("lipo: can't move temporary file"). This serializes the build step, so it
# does not matter whether the two dev scripts are started together or apart.
prebuild_locked() {
  local dart_define="$1" waited=0

  mkdir -p "$(dirname "$BUILD_LOCK")"
  while ! mkdir "$BUILD_LOCK" 2>/dev/null; do
    if [ "$waited" -eq 0 ]; then
      echo "==> another dev script is building; waiting for it to finish..."
    fi
    sleep 2
    waited=$((waited + 2))
    if [ "$waited" -ge 900 ]; then
      echo "error: build lock held for 15m. If nothing else is building, run:" >&2
      echo "         rmdir '$BUILD_LOCK'" >&2
      return 1
    fi
  done
  # shellcheck disable=SC2064
  trap "rmdir '$BUILD_LOCK' 2>/dev/null || true" RETURN

  echo "==> building once (serialized) ..."
  ( cd "$APP_DIR" && flutter build ios --simulator --debug --dart-define="$dart_define" )
}

# Resolves a simulator name or UDID to a UDID. Prefers an already-booted match.
resolve_sim() {
  local want="$1"
  xcrun simctl list devices available \
    | awk -v want="$want" '
        /^-- /            { next }
        /\(Booted\)/      { booted = 1 }
        { booted = /\(Booted\)/ }
        {
          if (match($0, /\(([0-9A-Fa-f-]{36})\)/)) {
            udid = substr($0, RSTART + 1, RLENGTH - 2)
            name = $0
            sub(/^[[:space:]]+/, "", name)
            sub(/[[:space:]]+\(.*$/, "", name)
            if (name == want || udid == want) {
              print (booted ? "0 " : "1 ") udid
            }
          }
        }' \
    | sort | head -1 | awk '{print $2}'
}

# Boots a simulator if it is not already booted, and opens Simulator.app.
boot_sim() {
  local udid="$1"
  if xcrun simctl list devices booted | grep -q "$udid"; then
    echo "==> already booted: $udid"
  else
    echo "==> booting: $udid"
    xcrun simctl boot "$udid" 2>/dev/null || true
  fi
}
