#!/bin/bash
# dr экспорт cloud sql в gcs (версионируемый бакет)
set -euo pipefail
PROJECT="${1:-tgops-prod}"
INSTANCE="${2:-$(gcloud sql instances list --project "$PROJECT" --filter='name~tgops-pg' --format='value(name)' | grep -v replica | head -1)}"
BUCKET="${3:-tgops-db-export-prod}"
DB="${DB:-tgops}"
TS="$(date +%Y%m%d-%H%M%S)"
URI="gs://${BUCKET}/${TS}.sql.gz"

echo "экспорт ${INSTANCE}/${DB} в ${URI}"
gcloud sql export sql "$INSTANCE" "$URI" --project "$PROJECT" --database "$DB"
echo "$URI" > /tmp/tgops_last_export
echo "готово: $URI"
