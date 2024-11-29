#!/bin/bash

NIC="$(ip -o -4 route show to default | awk '{print $5}')"

# Output file in HTML format
OUTPUT_FILE="/opt/script/monitoring_report.html"

# HTML Header
echo "<html>
<head>
    <title>System Monitoring Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        h2 { color: #2E8B57; }
        .section { margin-top: 20px; padding: 10px; }
        .cpu { color: #FFA500; }
        .memory, .disk, .network, .processes, .logs { color: #4682B4; }
        .error { color: #B22222; font-weight: bold; }
        pre { background-color: #f8f9fa; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1 style='color: #2E8B57;'>System Monitoring Report</h1>
    <h2>Date: $(date)</h2>" > "$OUTPUT_FILE"

# CPU Usage
echo "<div class='section cpu'><h2>CPU Usage:</h2><pre>" >> "$OUTPUT_FILE"
mpstat | awk '/all/ {print "CPU Load: " $3 "% idle"}' >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# Memory Usage
echo "<div class='section memory'><h2>Memory Usage:</h2><pre>" >> "$OUTPUT_FILE"
free -h | awk '/Mem/ {print "Total Memory: " $2 "\nUsed: " $3 "\nFree: " $4}' >> "$OUTPUT_FILE"
echo -e "\nSwap:\n$(free -h | awk '/Swap/ {print "Total: " $2 ", Used: " $3 ", Free: " $4}')" >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# Disk Usage
echo "<div class='section disk'><h2>Disk Usage:</h2><pre>" >> "$OUTPUT_FILE"
df -h | grep '^/dev' | awk '{print $1 ": " $5 " used, " $4 " available"}' >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# Network Traffic
echo "<div class='section network'><h2>Network Traffic:</h2><pre>" >> "$OUTPUT_FILE"
ifstat -i ${NIC} 1 1 | awk 'NR==3 {print "RX: " $1 " KB/s, TX: " $2 " KB/s"}' >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# Top 5 Memory Consuming Processes
echo "<div class='section processes'><h2>Top 5 Memory Consuming Processes:</h2><pre>" >> "$OUTPUT_FILE"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6 >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# Top 5 CPU Consuming Processes
echo "<div class='section processes'><h2>Top 5 CPU Consuming Processes:</h2><pre>" >> "$OUTPUT_FILE"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# System Logs Monitoring
echo "<div class='section logs'><h2>Recent Errors in System Logs:</h2><pre class='error'>" >> "$OUTPUT_FILE"
journalctl -p 3 -xb | tail -n 10 >> "$OUTPUT_FILE"
echo "</pre></div>" >> "$OUTPUT_FILE"

# HTML Footer
echo "</body></html>" >> "$OUTPUT_FILE"

# Send the email
mail -s "System Monitoring Report" -a "Content-Type: text/html" kho@nilpeter.com < "$OUTPUT_FILE"
