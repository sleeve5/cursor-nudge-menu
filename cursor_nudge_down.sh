#!/usr/bin/env zsh
set -euo pipefail

interval=180
pixels=1
print_config=0

usage() {
  printf 'Usage: %s [--interval seconds] [--print-config]\n' "${0:t}" >&2
}

positive_int() {
  [[ "$1" == <-> && "$1" -gt 0 ]]
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --interval)
      [[ "$#" -ge 2 ]] || { usage; exit 2; }
      interval="$2"
      shift 2
      ;;
    --print-config)
      print_config=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

positive_int "$interval" || { echo "interval must be a positive integer" >&2; exit 2; }

if [[ "$print_config" -eq 1 ]]; then
  echo "interval=$interval pixels=$pixels action=move"
  exit 0
fi

move_cursor_like_user() {
  swift -e "import CoreGraphics; import Darwin; let delta = CGFloat($pixels); if let event = CGEvent(source: nil) { let before = event.location; let after = CGPoint(x: before.x, y: before.y + delta); let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: after, mouseButton: .left); move?.post(tap: .cghidEventTap); usleep(100000); let current = CGEvent(source: nil)!.location; print(\"cursor_move before=\\(Int(before.x)),\\(Int(before.y)) after=\\(Int(current.x)),\\(Int(current.y))\") }"
}

while true; do
  sleep "$interval"
  move_cursor_like_user
done
