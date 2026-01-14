#!/bin/bash

# ==============================================================================
# Script Name    : logrotate.sh
# Description    : Deploys Logrotate configuration for the Monitoring Suite
# Author         : mrblue
# Version        : 1.0
# ==============================================================================

# --- Configuration ---
CONF_FILE="/etc/logrotate.d/system_monitoring"
LOG_USER="mrblue"
LOG_GROUP="adm"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)."
   exit 1
fi

# --- Create Logrotate Config ---
echo "Creating logrotate configuration at $CONF_FILE..."

cat << EOF > "$CONF_FILE"
/var/log/disk_monitor.log
/var/log/service_watchdog.log
/var/log/zombie_hunter.log
/var/log/thermal_monitor.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 $LOG_USER $LOG_GROUP
    sharedscripts
    postrotate
        /usr/bin/systemctl reload syslog.service > /dev/null 2>&1 || true
    endscript
}
EOF

# --- Finalize Permissions ---
chmod 644 "$CONF_FILE"

# --- Validation ---
echo "Validating logrotate configuration..."
logrotate -d "$CONF_FILE" &> /dev/null

if [ $? -eq 0 ]; then
    echo "Success: Logrotate configuration deployed and validated."
else
    echo "Error: Validation failed. Check /etc/logrotate.d/system_monitoring syntax."
    exit 1
fi
