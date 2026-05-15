#!/bin/bash
# выпустить самоподписанный серт с коротким сроком на ssl-target ноде (бот показал warning по сроку. - expired-cert.sh [домен] [дней])
set -euo pipefail
DOMAIN="${1:-ssl-target.tgops.xyz}"
DAYS="${2:-5}"
DST=/etc/nginx/certs
sudo mkdir -p "$DST"
sudo openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout "$DST/$DOMAIN.key" -out "$DST/$DOMAIN.crt" \
  -days "$DAYS" -subj "/CN=$DOMAIN"
echo "серт для $DOMAIN на $DAYS дней лежит в $DST, переключи nginx и reload"
