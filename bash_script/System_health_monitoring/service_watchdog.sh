#!/bin/bash
source /etc/monitor.conf 2>/dev/null
SERVICES=("${WATCHDOG_SERVICES[@]}")
LOG="/var/log/service_watchdog.log"

for SERVICE in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$SERVICE"; then
        echo "$(date '+%F %T') - WARN: $SERVICE down. Restarting..." >> "$LOG"
        systemctl restart "$SERVICE"
        sleep 5
        if systemctl is-active --quiet "$SERVICE"; then
            echo "$SERVICE recovered on $(hostname)" | mail -s "RECOVERY: $SERVICE" "$ALERT_EMAIL"
        else
            echo "CRITICAL: $SERVICE failed restart" | mail -s "CRITICAL: $SERVICE" "$ALERT_EMAIL"
        fi
    fi
done
