#!/bin/bash
# убрать следы хаос-сценария
set -euo pipefail
pkill yes 2>/dev/null || true
pkill stress-ng 2>/dev/null || true
rm -f /tmp/tgops-fill.bin
echo "очищено"
