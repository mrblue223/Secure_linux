#!/bin/bash

# ==============================================================================
# Script Name    : service_watchdog.sh
# Description    : Enterprise Service Monitor & Recovery Tool
# Author         : mrblue
# Version        : 1.0
# ==============================================================================

# --- Configuration ---
# List critical services to monitor (space separated)
CRITICAL_SERVICES=("nginx" "mysql" "docker")
EMAIL_RECIPIENT="admin@example.com"
LOG_FILE="/var/log/service_watchdog.log"
HOSTNAME=$(hostname -f)
SCRIPT_PATH=$(readlink -f "$0")

# --- UI Colors for Manual Execution ---
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# --- Logging Function ---
log_event() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] - $message" >> "$LOG_FILE"
}

# --- Service Health Check & Recovery ---
check_services() {
    for SERVICE in "${CRITICAL_SERVICES[@]}"; do
        # Check if service is active
        if systemctl is-active --quiet "$SERVICE"; then
            echo -e "${GREEN}[OK]${NC} $SERVICE is running."
        else
            echo -e "${RED}[FAILED]${NC} $SERVICE is down. Attempting recovery..."
            log_event "WARN" "$SERVICE detected as DOWN. Initiating restart."

            # Attempt Restart
            systemctl restart "$SERVICE"
            
            # Wait 5 seconds for initialization then re-verify
            sleep 5
            
            if systemctl is-active --quiet "$SERVICE"; then
                log_event "INFO" "$SERVICE successfully recovered."
                echo "$SERVICE recovered on $HOSTNAME" | mail -s "[RECOVERY] $SERVICE Restored" "$EMAIL_RECIPIENT"
            else
                log_event "CRITICAL" "Manual intervention required: $SERVICE failed to restart."
                echo "CRITICAL: $SERVICE is down on $HOSTNAME and failed to restart." | mail -s "[CRITICAL] $SERVICE Down" "$EMAIL_RECIPIENT"
            fi
        fi
    done
}

# --- Automated Cron Setup ---
setup_cron() {
    echo "--- Watchdog Scheduling Setup ---"
    echo "Recommended: Run every 5 minutes (*/5 * * * *) for high availability."
    echo ""
    read -p "Enter cron schedule (default '*/5 * * * *'): " CRON_INPUT
    CRON_SCHEDULE=${CRON_INPUT:-"*/5 * * * *"}

    (crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") && { echo "Job already exists."; exit 1; }
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_PATH") | crontab -
    echo "Success: Watchdog scheduled for $CRON_SCHEDULE"
}

# --- Entry Point ---
case "$1" in
    --setup)
        setup_cron
        ;;
    *)
        check_services
        ;;
esac
