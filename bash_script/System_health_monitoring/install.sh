#!/bin/bash

# ==============================================================================
# Script Name    : install.sh
# Description    : Secure Remote Installer for Monitoring Suite
# Author         : mrblue
# Version        : 2.1
# ==============================================================================

# --- Configuration ---
REPO_URL="https://github.com/mrblue223/Secure_linux.git"
REPO_SUBDIR="bash_script/System_health_monitoring"
TARGET_DIR="/usr/local/bin"
LOG_DIR="/var/log"
TEMP_DIR="/tmp/secure_linux_install"
SCRIPTS=("disk_monitor.sh" "logrotate.sh" "service_watchdog.sh" "thermal_monitor.sh" "zombie_hunter.sh")

# --- Pre-flight Checks ---
if [[ $EUID -ne 0 ]]; then
   echo "CRITICAL: This installer must be run as root (sudo)."
   exit 1
fi

# Detect OS and set Package Manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS="unknown"
fi

# --- Interactive Configuration ---
echo "--- Monitoring Suite Configuration ---"
read -p "Enter Alert Email Address: " USER_EMAIL
read -p "Enter System Username for Logs (default: mrblue): " MON_USER
MON_USER=${MON_USER:-"mrblue"}

# Ensure user exists, fallback to root if not
if ! id "$MON_USER" &>/dev/null; then
    echo "Warning: User $MON_USER not found. Logs will be owned by root."
    MON_USER="root"
fi

# --- Dependency Installation ---
echo "Checking dependencies for $OS..."
case "$OS" in
    ubuntu|debian|kali)
        apt update && apt install -y git mailutils lm-sensors
        ;;
    centos|rhel|fedora)
        dnf install -y git s-nail lm_sensors
        ;;
    *)
        echo "Manual dependency check required: git, mail, lm-sensors"
        ;;
esac

# --- Remote Deployment ---
echo "Cloning repository..."
rm -rf "$TEMP_DIR"
git clone --quiet "$REPO_URL" "$TEMP_DIR"

if [ ! -d "$TEMP_DIR/$REPO_SUBDIR" ]; then
    echo "Error: Directory structure mismatch in Repository."
    exit 1
fi

cd "$TEMP_DIR/$REPO_SUBDIR" || exit

echo "Deploying and patching scripts..."
for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
        # 1. Patch the email address and user into the script before moving
        sed -i "s/your-email@example.com/$USER_EMAIL/g" "$SCRIPT"
        sed -i "s/admin@example.com/$USER_EMAIL/g" "$SCRIPT"
        sed -i "s/MON_USER=\"mrblue\"/MON_USER=\"$MON_USER\"/g" "$SCRIPT"

        # 2. Move to target directory
        cp "$SCRIPT" "$TARGET_DIR/"
        chmod +x "$TARGET_DIR/$SCRIPT"
        
        # 3. Initialize log files
        LOG_FILE="$LOG_DIR/${SCRIPT%.sh}.log"
        touch "$LOG_FILE"
        chown "$MON_USER:adm" "$LOG_FILE" 2>/dev/null || chown root:adm "$LOG_FILE"
        chmod 640 "$LOG_FILE"
        
        echo "OK: Installed $SCRIPT"
    fi
done

# 4. Trigger Logrotate Setup
if [ -x "$TARGET_DIR/logrotate.sh" ]; then
    echo "Setting up log rotation..."
    "$TARGET_DIR/logrotate.sh"
fi

# --- Cleanup ---
rm -rf "$TEMP_DIR"

echo "--- INSTALLATION COMPLETE ---"
echo "Log files: /var/log/*.log"
echo "Binaries:  /usr/local/bin/"
echo "Next step: Run 'disk_monitor.sh --setup' to automate."
