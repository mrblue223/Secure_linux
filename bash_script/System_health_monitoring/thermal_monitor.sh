#!/bin/bash

# ==============================================================================
# Script Name    : thermal_monitor.sh
# Description    : Monitors CPU/GPU temps and alerts on thermal limits.
# Author         : mrblue
# Version        : 1.0
# ==============================================================================

# --- Configuration ---
TEMP_LIMIT=85
EMAIL_RECIPIENT="admin@example.com"
LOG_FILE="/var/log/thermal_monitor.log"
HOSTNAME=$(hostname -f)
SCRIPT_PATH=$(readlink -f "$0")

# --- Dependency Check ---
if ! command -v sensors &> /dev/null; then
    echo "CRITICAL: lm-sensors not installed." | mail -s "Monitor Failure: $HOSTNAME" "$EMAIL_RECIPIENT"
    exit 1
fi

# --- Execution ---
check_thermal() {
    # Parse the highest current temperature from sensors
    # Filter targets 'Package id 0', 'Core 0', or generic 'temp1'
    CURRENT_MAX=$(sensors | grep -E 'Package id 0|Core 0|temp1' | awk '{print $4}' | grep -o '[0-9.]*' | head -n1 | cut -d. -f1)

    if [[ -n "$CURRENT_MAX" ]] && [ "$CURRENT_MAX" -ge "$TEMP_LIMIT" ]; then
        SUBJECT="[CRITICAL] Thermal Throttling Alert: $HOSTNAME"
        BODY="Current system temperature is ${CURRENT_MAX}°C (Threshold: ${TEMP_LIMIT}°C).\n\nRaw Sensor Data:\n$(sensors)"

        echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL_RECIPIENT"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - CRITICAL: Temperature hit ${CURRENT_MAX}C." >> "$LOG_FILE"
    fi
}

setup_cron() {
    echo "Suggested schedule: Every 5-10 minutes (*/10 * * * *)"
    read -p "Enter cron string: " CRON_INPUT
    CRON_SCHEDULE=${CRON_INPUT:-"*/10 * * * *"}
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_PATH") | crontab -
    echo "Scheduled: $CRON_SCHEDULE"
}

case "$1" in
    --setup) setup_cron ;;
    *) check_thermal ;;
esac
