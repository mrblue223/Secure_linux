# 🛡️ Secure Linux Monitoring Suite
**Author:** mrblue
**Version:** 1.0

# 📋 1. Prerequisites & Dependencies
Before installation, ensure your system has the necessary tools to send emails and read hardware sensors.

# Identify your OS and Install: 

## Debian, Ubuntu, or Kali Linux:
    
    sudo apt update && sudo apt install git mailutils lm-sensors -y

## For RHEL, CentOS, or Fedora:
    
    sudo dnf install git s-nail lm_sensors -y

## Hardware Sensor Setup:
You must initialize the sensors for the thermal monitor to function:
    
    sudo sensors-detect

Note: Press ENTER for all default prompts.

# 🚀 2. Installation
The suite features a Master Installer that clones the repository and configures your environment automatically.

## The One-Liner Install:
Run this command to pull the latest version directly from GitHub:
    
    curl -sSL https://raw.githubusercontent.com/mrblue223/Secure_linux/main/install.sh | sudo bash

## What the Installer Does:
- Prompts for Configuration: Asks for your alert email and preferred system user.
- Creates /etc/monitor.conf: Generates a central settings file.
- Deploys Binaries: Moves scripts to /usr/local/bin for system-wide access.
- Initializes Logs: Creates log files in /var/log with secure permissions (640).
- Sets up Rotation: Configures logrotate to prevent disk bloat.

# ⚙️ 3. Configuration
All scripts source their settings from a single file located at monitor.conf

## Editing Settings:
Open the config file to change alert thresholds or the list of monitored services:

    sudo nano monitor.conf

## Key Parameters:
- **ALERT_EMAIL:** The address where all alerts are sent.
- **DISK_THRESHOLD:** Percentage (default 90) before a disk alert triggers.
- **TEMP_LIMIT:** Celsius (default 85) before a thermal alert triggers.
- **WATCHDOG_SERVICES:** A list of services (e.g., nginx, docker) to monitor for uptime.

# ⏰ 4. Automation (Cron Setup)
After installation, you must decide how often each script runs. Each monitoring script contains a --setup flag to handle this.

## Example: Automating the Disk Monitor
sudo disk_monitor.sh --setup

## recommendations
- Script,Recommended Frequency,Purpose
- service_watchdog.sh,Every 5 minutes,Ensures critical services are always up.
- thermal_monitor.sh,Every 10 minutes,Protects hardware from overheating.
- disk_monitor.sh,Hourly,Monitors storage growth.
- zombie_hunter.sh,Hourly,Cleans up the process table.

# 📂 5. Logging & Maintenance

## Viewing Logs:
Each script logs events to /var/log/. To see live monitoring events:

    tail -f /var/log/*.log

## Log Rotation:
The suite includes a logrotate configuration to ensure logs are compressed weekly and kept for 4 weeks. This happens automatically in the background.

## 🛠️ 6. Troubleshooting
- No Emails? Ensure your local mail agent is configured correctly. Try sending a test: echo "Test" | mail -s "Test Alert" your@email.com
- Permission Denied? Ensure you are running scripts with sudo or as the root user.
- Sensors missing? Re-run sudo sensors-detect and restart the kmod service or reboot.





















