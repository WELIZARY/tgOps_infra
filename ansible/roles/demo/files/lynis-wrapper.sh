#!/bin/bash
# обёртка: гоняет реальный lynis под sudo, отдаёт находки в формате который ждёт бот
sudo /usr/sbin/lynis "$@" >/dev/null 2>&1
sudo awk -F'|' '
 /^warning\[\]=/    { s=$0; sub(/^warning\[\]=/,"",s);    split(s,a,"|"); print "[WARNING] " a[1] " - " a[2] }
 /^suggestion\[\]=/ { s=$0; sub(/^suggestion\[\]=/,"",s); split(s,a,"|"); print "[SUGGESTION] " a[1] " - " a[2] }
' /var/log/lynis-report.dat 2>/dev/null | head -50
