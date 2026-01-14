#SYSTEM MONITORING SUITE

**Author**: mrblue **Version**: 1.0 

# OVERVIEW

This suite consists of four specialized monitoring scripts designed for high-availability Linux environments. Each script is modular, logs to /var/log/, and includes a self-service cron installation feature.

# 1. SCRIPT DEFINITIONS
## Disk Space Alert (disk_monitor.sh)

Monitors mount points and alerts via email if usage exceeds 90%. It ignores virtual and read-only filesystems like tmpfs and squashfs to reduce noise.

## Service Watchdog (service_watchdog.sh)

Checks if critical services (Nginx, MySQL, Docker) are active. If a service is down, it attempts a restart, waits for stabilization, and verifies the recovery status.

## Zombie Process Hunter (zombie_hunter.sh)

Identifies "defunct" processes. Because zombies are already dead and cannot be killed, this script captures the Parent PID (PPID) so the administrator can restart the parent process to clean the process table.

## Hardware Thermal Monitor (thermal_monitor.sh)

Uses lm-sensors to track CPU package temperatures. It alerts the administrator if the system approaches thermal throttling limits (default 85°C).

## Log ration

This script is designed to be the "single source of truth." It automates the directory structure, log initialization, script placement, and log rotation in one idempotent execution.

# 2. INSTALLATION REQUIREMENTS
**System Dependencies**

You must install the following utilities for mail delivery and sensor reading:

**Debian/Ubuntu:** sudo apt update && sudo apt install mailutils lm-sensors -y

**RHEL/CentOS:** sudo dnf install mailx lm_sensors -y
Sensor Initialization

Before running the thermal monitor, detect your hardware sensors: sudo sensors-detect (Press ENTER for all defaults)

# 3. DEPLOYMENT STEPS
## Step 1: Permissions

Set the execution bit on all downloaded scripts: chmod +x disk_monitor.sh service_watchdog.sh zombie_hunter.sh thermal_monitor.sh logrotate.sh
## Step 2: Logging Setup

Create the required log files in the /var/log directory: sudo touch /var/log/disk_monitor.log /var/log/service_watchdog.log /var/log/zombie_hunter.log /var/log/thermal_monitor.log sudo chown $USER /var/log/*.log
## Step 3: Automated Scheduling

Run each script with the --setup flag to interactively add it to your crontab: ./disk_monitor.sh --setup ./service_watchdog.sh --setup ./zombie_hunter.sh --setup ./thermal_monitor.sh --setup
# 4. LOGGING & AUDIT

Every action is recorded in its respective log file. You can monitor system health in real-time using: tail -f /var/log/*.log


