#!/bin/bash

# ==============================================================================
# Script Name    : zombie_hunter.sh
# Description    : Detects and reports defunct processes.
# Author         : mrblue
# Version        : 1.0
# ==============================================================================

# --- Configuration ---
EMAIL_RECIPIENT="admin@example.com"
HOSTNAME=$(hostname -f)
LOG_FILE="/var/log/zombie_hunter.log"
SCRIPT_PATH=$(readlink -f "$0")

# --- Execution ---
check_zombies() {
    # Count processes with 'Z' (Zombie) status
    ZOMBIE_COUNT=$(ps aux | awk '$8=="Z"' | wc -l)

    if [ "$ZOMBIE_COUNT" -gt 0 ]; then
        # Capture process details including PPID (Parent Process ID)
        ZOMBIE_LIST=$(ps -ef | grep '[d]efunct' | grep -v grep)
        
        SUBJECT="[WARN] $ZOMBIE_COUNT Zombie Processes on $HOSTNAME"
        BODY="The following zombie processes were detected:\n\n$ZOMBIE_LIST\n\nNote: You must address the Parent PID (PPID) to clear these."

        echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL_RECIPIENT"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - FOUND: $ZOMBIE_COUNT zombies." >> "$LOG_FILE"
    fi
}

setup_cron() {
    echo "Suggested schedule: Every hour (0 * * * *)"
    read -p "Enter cron string: " CRON_INPUT
    CRON_SCHEDULE=${CRON_INPUT:-"0 * * * *"}
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_PATH") | crontab -
    echo "Scheduled: $CRON_SCHEDULE"
}

case "$1" in
    --setup) setup_cron ;;
    *) check_zombies ;;
esac
