#!/bin/bash
set -euo pipefail
LAYER="${1:?нужен слой}"
ROOT="$(cd "$(dirname "$0")/../../terraform/envs/prod" && pwd)"
DIR="$ROOT/$LAYER"
[ -d "$DIR" ] || { echo "нет слоя $LAYER"; exit 1; }
cd "$DIR"
terraform init -backend-config=backend.hcl
terraform destroy
