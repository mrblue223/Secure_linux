#!/bin/bash
source /etc/monitor.conf 2>/dev/null
LIMIT=${TEMP_LIMIT:-85}
LOG="/var/log/thermal_monitor.log"

TEMP=$(sensors | grep -E 'Package id 0|Core 0|temp1' | awk '{print $4}' | grep -o '[0-9.]*' | head -n1 | cut -d. -f1)

if [[ -n "$TEMP" ]] && [ "$TEMP" -ge "$LIMIT" ]; then
    MSG="CRITICAL: Temperature hit ${TEMP}C (Limit: ${LIMIT}C)"
    echo -e "$MSG\n\n$(sensors)" | mail -s "Thermal Alert: $(hostname)" "$ALERT_EMAIL"
    echo "$(date '+%F %T') - $MSG" >> "$LOG"
fi
