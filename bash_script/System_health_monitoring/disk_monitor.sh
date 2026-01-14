#!/bin/bash

# ==============================================================================
# Script Name    : disk_monitor.sh
# Description    : Enterprise-grade disk usage monitor with auto-cron installation.
# Author         : mrblue
# Version        : 1.0
# ==============================================================================

# --- Configuration ---
THRESHOLD=90
EMAIL_RECIPIENT="admin@example.com"
HOSTNAME=$(hostname -f)
LOG_FILE="/var/log/disk_monitor.log"
SCRIPT_PATH=$(readlink -f "$0")

# --- Dependency Check ---
check_dependencies() {
    if ! command -v mail &> /dev/null; then
        echo "Error: 'mail' command not found. Please install mailutils or smail."
        exit 1
    fi
}

# --- Monitor Logic ---
run_monitor() {
    check_dependencies
    # Exclude pseudo, duplicate, and read-only filesystems
    df -Ph -x tmpfs -x devtmpfs -x squashfs -x iso9660 | grep -v '^Filesystem' | while read -r line; do
        USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        MOUNT=$(echo "$line" | awk '{print $6}')

        if [[ "$USAGE" =~ ^[0-9]+$ ]] && [ "$USAGE" -ge "$THRESHOLD" ]; then
            SUBJECT="[PRIORITY ALERT] High Disk Usage: $HOSTNAME"
            MESSAGE="Host: $HOSTNAME\nMount Point: $MOUNT\nCurrent Usage: ${USAGE}%\n\nFull Partition Detail:\n$(df -h "$MOUNT")"
            
            echo -e "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL_RECIPIENT"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $MOUNT at ${USAGE}% - Email dispatched." >> "$LOG_FILE"
        fi
    done
}

# --- Automated Cron Setup ---
setup_cron() {
    echo "--- Cron Scheduling Setup ---"
    echo "Suggestions:"
    echo "1) Every hour (0 * * * *)      - Recommended for production"
    echo "2) Every 15 mins (*/15 * * * *) - For high-churn logging servers"
    echo "3) Daily at midnight (0 0 * * *) - For low-priority backup servers"
    echo ""
    read -p "Enter your preferred cron schedule (or press Enter for Every Hour): " CRON_INPUT
    CRON_SCHEDULE=${CRON_INPUT:-"0 * * * *"}

    # Check if job already exists to prevent duplicates
    (crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") && { echo "Error: Job already exists in crontab."; exit 1; }

    # Add to crontab
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_PATH") | crontab -
    echo "Success: Monitor scheduled with: $CRON_SCHEDULE"
}

# --- Entry Point ---
case "$1" in
    --setup)
        setup_cron
        ;;
    *)
        run_monitor
        ;;
esac
