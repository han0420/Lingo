#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/dist/Lingo.app"

pkill -x Lingo >/dev/null 2>&1 || true
"$ROOT_DIR/script/assemble_app.sh" debug "$APP_BUNDLE" >/dev/null
/usr/bin/open -n "$APP_BUNDLE"

case "$MODE" in
  run) ;;
  --verify|verify) sleep 2; pgrep -x Lingo >/dev/null ;;
  *) echo "usage: $0 [run|--verify]" >&2; exit 2 ;;
esac
