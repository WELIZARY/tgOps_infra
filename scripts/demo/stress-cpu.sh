#!/bin/bash
# нагрузить cpu на demo ноде, чтобы прилетел алерт. (stress-cpu.sh [секунды])
set -euo pipefail
SECONDS_RUN="${1:-180}"
if command -v stress-ng >/dev/null 2>&1; then
  stress-ng --cpu "$(nproc)" --timeout "${SECONDS_RUN}s"
else
  # fallback без stress-ng
  for i in $(seq 1 "$(nproc)"); do yes >/dev/null & done
  sleep "$SECONDS_RUN"
  pkill yes || true
fi
echo "нагрузка cpu завершена"
