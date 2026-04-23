#!/bin/bash

set -euo pipefail

SOURCE=""
DEST=""
NAME=""

while getopts ":s:d:n:" opt; do
    case ${opt} in
        s) SOURCE="${OPTARG}" ;;
        d) DEST="${OPTARG}" ;;
        n) NAME="${OPTARG}" ;;
        \?) echo "Invalid option: -${OPTARG}" >&2
            exit 1 ;;
        :) echo "Option -${OPTARG} requires an argument." >&2
            exit 1 ;;
    esac
done

# Validate required arguments
if [ -z "${SOURCE}" ] || [ -z "${DEST}" ] || [ -z "${NAME}" ]; then
  echo "Error: Required arguments missing. Usage: $0 -s <source> -d <destination> -n <name>" >&2
  exit 1
fi

# Validate source exists and is readable
if [ ! -e "${SOURCE}" ]; then
  echo "Error: Source not found: ${SOURCE}" >&2
  exit 1
fi

if [ ! -r "${SOURCE}" ]; then
  echo "Error: Source is not readable: ${SOURCE}" >&2
  exit 1
fi

# Validate destination directory exists and is writable
if [ ! -d "${DEST}" ]; then
  echo "Error: Destination directory not found: ${DEST}" >&2
  exit 1
fi

if [ ! -w "${DEST}" ]; then
  echo "Error: Destination directory is not writable: ${DEST}" >&2
  exit 1
fi

# Check available disk space
REQUIRED_SPACE=$(du -sh "${SOURCE}" 2>/dev/null | cut -f1 | sed 's/[^0-9]//g')
AVAILABLE_SPACE=$(df "${DEST}" 2>/dev/null | tail -1 | awk '{print $4}')

if [ "${REQUIRED_SPACE}" -gt "${AVAILABLE_SPACE}" ]; then
  echo "Error: Insufficient disk space. Required: ~${REQUIRED_SPACE}KB, Available: ${AVAILABLE_SPACE}KB" >&2
  exit 1
fi

# Backup a directory and store it in a backup folder with a timestamp
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="${DEST}/${NAME}_backup_${TIMESTAMP}.tar.gz"

if ! tar -czf "${BACKUP_FILE}" "${SOURCE}" 2>/dev/null; then
  echo "Error: Backup failed" >&2
  rm -f "${BACKUP_FILE}"
  exit 1
fi

if [ ! -f "${BACKUP_FILE}" ]; then
  echo "Error: Backup file was not created" >&2
  exit 1
fi

echo "Backup completed successfully: ${BACKUP_FILE}"
