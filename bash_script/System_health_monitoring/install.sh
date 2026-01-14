#!/bin/bash
# install.sh Version 2.2 - Master Setup

REPO_URL="https://github.com/mrblue223/Secure_linux.git"
REPO_SUBDIR="bash_script/System_health_monitoring"
TARGET_DIR="/usr/local/bin"
CONF_FILE="/etc/monitor.conf"
TEMP_DIR="/tmp/secure_linux_install"

if [[ $EUID -ne 0 ]]; then echo "Must run as root."; exit 1; fi

# Interactive Config Generation
echo "--- Configuration Setup ---"
read -p "Alert Email: " USER_EMAIL
read -p "Username (default: mrblue): " SEL_USER
SEL_USER=${SEL_USER:-"mrblue"}

cat << EOF > "$CONF_FILE"
ALERT_EMAIL="$USER_EMAIL"
DISK_THRESHOLD=90
TEMP_LIMIT=85
WATCHDOG_SERVICES=("nginx" "mysql" "docker")
MON_USER="$SEL_USER"
LOG_GROUP="adm"
EOF
chmod 644 "$CONF_FILE"

# Deployment
git clone --quiet "$REPO_URL" "$TEMP_DIR"
cd "$TEMP_DIR/$REPO_SUBDIR" || exit

for SCRIPT in *.sh; do
    cp "$SCRIPT" "$TARGET_DIR/"
    chmod +x "$TARGET_DIR/$SCRIPT"
    LOG="/var/log/${SCRIPT%.sh}.log"
    touch "$LOG" && chown "$SEL_USER:adm" "$LOG" && chmod 640 "$LOG"
done

# Run logrotate script once to initialize system config
/usr/local/bin/logrotate.sh
echo "Installation complete."
