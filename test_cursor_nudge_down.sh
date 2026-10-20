#!/usr/bin/env zsh
set -euo pipefail

script_dir=${0:A:h}
script="$script_dir/cursor_nudge_down.sh"

output="$("$script" --print-config)"
[[ "$output" == "interval=180 pixels=1 action=move" ]]

output="$("$script" --interval 60 --print-config)"
[[ "$output" == "interval=60 pixels=1 action=move" ]]

if "$script" --interval 0 --print-config >/dev/null 2>&1; then
  echo "expected invalid interval to fail" >&2
  exit 1
fi
