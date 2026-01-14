#!/bin/bash
# Source central config
source /etc/monitor.conf 2>/dev/null || { echo "Config missing"; exit 1; }

# Variables from config
THRESHOLD=${DISK_THRESHOLD:-90}
EMAIL=${ALERT_EMAIL}
LOG="/var/log/disk_monitor.log"

df -Ph -x tmpfs -x devtmpfs -x squashfs | grep -v '^Filesystem' | while read -r line; do
    USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    MOUNT=$(echo "$line" | awk '{print $6}')

    if [[ "$USAGE" =~ ^[0-9]+$ ]] && [ "$USAGE" -ge "$THRESHOLD" ]; then
        MSG="ALERT: $MOUNT is at ${USAGE}% capacity on $(hostname)"
        echo -e "$MSG\n\n$(df -h "$MOUNT")" | mail -s "Disk Alert: $MOUNT" "$EMAIL"
        echo "$(date '+%F %T') - $MSG" >> "$LOG"
    fi
done
