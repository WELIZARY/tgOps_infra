#!/bin/bash
# забить диск временным файлом, чтобы сработал disk алерт
set -euo pipefail
SIZE_GB="${1:-5}"
F=/tmp/tgops-fill.bin
dd if=/dev/zero of="$F" bs=1M count=$((SIZE_GB*1024)) status=progress
echo "создан $F на ${SIZE_GB}gb, удалить scripts/demo/clear.sh"
