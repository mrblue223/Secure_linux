#!/bin/bash
# ==============================================================================
# Script Name    : install.sh
# Description    : Secure Remote Installer for Monitoring Suite
# Author         : mrblue | Version: 2.2
# ==============================================================================

REPO_URL="https://github.com/mrblue223/Secure_linux.git"
REPO_SUBDIR="bash_script/System_health_monitoring"
TARGET_DIR="/usr/local/bin"
CONF_FILE="/etc/monitor.conf"
TEMP_DIR="/tmp/secure_linux_install"

if [[ $EUID -ne 0 ]]; then echo "CRITICAL: Run as root."; exit 1; fi

echo "--- Monitoring Suite Setup ---"
read -p "Enter Alert Email: " USER_EMAIL
read -p "Enter System Username (default: mrblue): " SEL_USER
SEL_USER=${SEL_USER:-"mrblue"}

# Create Centralized Config
cat << EOF > "$CONF_FILE"
ALERT_EMAIL="$USER_EMAIL"
DISK_THRESHOLD=90
TEMP_LIMIT=85
WATCHDOG_SERVICES=("nginx" "mysql" "docker")
MON_USER="$SEL_USER"
LOG_GROUP="adm"
EOF
chmod 644 "$CONF_FILE"

# Clone and Deploy
rm -rf "$TEMP_DIR"
git clone --quiet "$REPO_URL" "$TEMP_DIR"
cd "$TEMP_DIR/$REPO_SUBDIR" || { echo "Directory error"; exit 1; }

for SCRIPT in *.sh; do
    cp "$SCRIPT" "$TARGET_DIR/"
    chmod +x "$TARGET_DIR/$SCRIPT"
    
    # Initialize Log
    LOG="/var/log/${SCRIPT%.sh}.log"
    touch "$LOG"
    chown "$SEL_USER:adm" "$LOG"
    chmod 640 "$LOG"
    echo "Installed: $SCRIPT"
done

# Run Logrotate setup from binary dir
"$TARGET_DIR/logrotate.sh"

rm -rf "$TEMP_DIR"
echo "--- SUCCESS: Suite Installed ---"
