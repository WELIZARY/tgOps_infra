#!/bin/bash
# dr восстановление cloud sql из gcs (import.sh <latest|gs://.../file.sql.gz> [project] [instance] [bucket])
set -euo pipefail
WHICH="${1:-latest}"
PROJECT="${2:-tgops-prod}"
INSTANCE="${3:-$(gcloud sql instances list --project "$PROJECT" --filter='name~tgops-pg' --format='value(name)' | grep -v replica | head -1)}"
BUCKET="${4:-tgops-db-export-prod}"
DB="${DB:-tgops}"

if [ "$WHICH" = latest ]; then
  URI="$(gsutil ls "gs://${BUCKET}/*.sql.gz" | sort | tail -1)"
else
  URI="$WHICH"
fi
[ -n "$URI" ] || { echo "не найден дамп в gs://${BUCKET}"; exit 1; }

echo "импорт ${URI} в ${INSTANCE}/${DB}"
gcloud sql import sql "$INSTANCE" "$URI" --project "$PROJECT" --database "$DB" --quiet
echo "готово"
