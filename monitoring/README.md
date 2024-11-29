## Prerequisites
- Install ifstat


## CRONTAB
0 * * * * /path/to/monitoring.sh >> /var/log/system_monitor.log

## Send logs to email
1. install mailutils (ubuntu/debian) or mailx (RHEL/CentOS)
2. add to crontab:
  0 * * * tail -n 25 /var/log/system_monitor.log | mail -s "Daily Report" -a /var/log/system_monitor.log recipient@example.com



### monitoring_html.sh
This script sends output as HTML
