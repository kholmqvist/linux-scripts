#!/bin/bash

set -euo pipefail

LOG_FILE=""
BACKUP_DIR=""
LOG_NAME=""

while getopts ":s:d:n:" opt; do
  case ${opt} in
    s) LOG_FILE="${OPTARG}" ;;
    d) BACKUP_DIR="${OPTARG}" ;;
    n) LOG_NAME="${OPTARG}" ;;
    \?) echo "Invalid option: -${OPTARG}" >&2
        exit 1 ;;
    :) echo "Option -${OPTARG} requires an argument." >&2
        exit 1 ;;
  esac
done

# Validate required arguments
if [ -z "${LOG_FILE}" ] || [ -z "${BACKUP_DIR}" ] || [ -z "${LOG_NAME}" ]; then
  echo "Error: Required arguments missing. Usage: $0 -s <log_file> -d <backup_dir> -n <log_name>" >&2
  exit 1
fi

# Validate log file exists
if [ ! -f "${LOG_FILE}" ]; then
  echo "Error: Log file not found: ${LOG_FILE}" >&2
  exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "${BACKUP_DIR}" ]; then
  if ! mkdir -p "${BACKUP_DIR}"; then
    echo "Error: Cannot create backup directory: ${BACKUP_DIR}" >&2
    exit 1
  fi
fi

# Verify backup directory is writable
if [ ! -w "${BACKUP_DIR}" ]; then
  echo "Error: Backup directory is not writable: ${BACKUP_DIR}" >&2
  exit 1
fi

# Rotate and compress logs
TIMESTAMP=$(date +"%Y%m%d")
if ! mv "${LOG_FILE}" "${BACKUP_DIR}/${LOG_NAME}_${TIMESTAMP}.log"; then
  echo "Error: Failed to move log file" >&2
  exit 1
fi

if ! gzip "${BACKUP_DIR}/${LOG_NAME}_${TIMESTAMP}.log"; then
  echo "Error: Failed to compress log file" >&2
  exit 1
fi

if ! touch "${LOG_FILE}"; then
  echo "Error: Failed to create new log file" >&2
  exit 1
fi

echo "Log rotation completed successfully."
