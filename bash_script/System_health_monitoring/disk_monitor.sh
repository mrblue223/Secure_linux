#!/bin/bash
# disk_monitor.sh - Sources /etc/monitor.conf

source /etc/monitor.conf 2>/dev/null || ALERT_EMAIL="admin@example.com"
THRESHOLD=${DISK_THRESHOLD:-90}
LOG_FILE="/var/log/disk_monitor.log"

# Logic for checking partitions
df -Ph -x tmpfs -x devtmpfs -x squashfs | grep -v '^Filesystem' | while read -r line; do
    USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    MOUNT=$(echo "$line" | awk '{print $6}')

    if [[ "$USAGE" =~ ^[0-9]+$ ]] && [ "$USAGE" -ge "$THRESHOLD" ]; then
        echo "Disk Alert: $MOUNT is at ${USAGE}%" | mail -s "Disk Alert" "$ALERT_EMAIL"
        echo "$(date) - ALERT: $MOUNT at ${USAGE}%" >> "$LOG_FILE"
    fi
done
