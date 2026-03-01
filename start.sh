#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Stop previous instance if running.
pkill -f "CalendarPlusApp" >/dev/null 2>&1 || true

swift build --product CalendarPlusApp
BIN_PATH="$(swift build --show-bin-path)/CalendarPlusApp"

if [[ ! -x "$BIN_PATH" ]]; then
  echo "Failed to find executable: $BIN_PATH" >&2
  exit 1
fi

exec "$BIN_PATH"
