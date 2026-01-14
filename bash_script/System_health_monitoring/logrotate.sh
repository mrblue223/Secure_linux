#!/bin/bash
source /etc/monitor.conf 2>/dev/null
USER=${MON_USER:-"mrblue"}
GROUP=${LOG_GROUP:-"adm"}

cat << EOF > /etc/logrotate.d/system_monitoring
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
    create 0640 $USER $GROUP
    sharedscripts
    postrotate
        /usr/bin/systemctl reload syslog.service > /dev/null 2>&1 || true
    endscript
}
EOF
