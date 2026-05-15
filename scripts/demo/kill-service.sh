#!/bin/bash
# уронить сервис на demo ноде, чтобы сработал service_down алерт (kill-service.sh <имя сервиса, по умолчанию nginx>)
set -euo pipefail
SVC="${1:-nginx}"
sudo systemctl stop "$SVC"
echo "$SVC остановлен, поднять: sudo systemctl start $SVC"
