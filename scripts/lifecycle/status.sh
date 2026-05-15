#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../terraform/envs/prod" && pwd)"
for L in 10-platform 20-data 30-apps 40-observability; do
  D="$ROOT/$L"
  if [ -d "$D" ] && terraform -chdir="$D" state list >/dev/null 2>&1 \
     && [ -n "$(terraform -chdir="$D" state list 2>/dev/null)" ]; then
    echo "UP   $L"
  else
    echo "down $L"
  fi
done
