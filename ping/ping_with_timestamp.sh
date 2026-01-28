#!/bin/bash
# Kenneth Holmqvist
# 30 April 2025
#

# Color Variables
color_red='\033[0;31m'
color_clear='\033[0m'

# Check if an IP address was provided
if [ -z "${1}" ]; then
  echo "Usage: ${0} <IP_ADDRESS>"
  exit 1
fi

IP="${1}"
LOGFILE="${IP}.log"
FAILURE_LOGFILE="${IP}_failures.log"
BUFFER_SIZE=500

# safe temp file (includes ip)
TEMP_FILE=$(mktemp "/tmp/ping_${IP//./_}.tmp")

echo "Pinging ${IP} with timestamps..."
echo "Logging output to ${LOGFILE}"
echo "Press Ctrl+C to stop."

# Cleanup temp file on exit
trap "rm -f ${TEMP_FILE}" EXIT

# Use ping in a loop to capture and timestamp each line
ping -D "${IP}" | while read -r line; do
  TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
	ENTRY="${TIMESTAMP} ${line}"
  
	# Log to temp and main log file
  echo "${ENTRY}" >> "${TEMP_FILE}"
	tail -n ${BUFFER_SIZE} "${TEMP_FILE}" > "${LOGFILE}"

  # Pring to termina with red timestamp
	echo -e "${color_red}${TIMESTAMP}${color_clear} ${line}"

  # Detect failure conditions
  if [[ "${line}" =~ "Destination Host Unreachable" ]] || \
     [[ "${line}" =~ "Request timeout" ]] || \
     [[ "${line}" =~ "100% packet loss" ]]; then
      echo "${ENTRY}" >> "${FAILURE_LOGFILE}"
  fi
done
