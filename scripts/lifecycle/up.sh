#!/bin/bash
# up.sh <10-platform|20-data|30-apps|40-observability>
set -euo pipefail
LAYER="${1:?нужен слой}"
ROOT="$(cd "$(dirname "$0")/../../terraform/envs/prod" && pwd)"
DIR="$ROOT/$LAYER"
[ -d "$DIR" ] || { echo "нет слоя $LAYER"; exit 1; }
cd "$DIR"
[ -f backend.hcl ] || cp backend.hcl.example backend.hcl
[ -f terraform.tfvars ] || cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl -upgrade
terraform apply
