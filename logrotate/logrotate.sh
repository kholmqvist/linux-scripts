#!/bin/bash

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


# Rotate and compress logs
TIMESTAMP=$(date +"%Y%m%d")
mv ${LOG_FILE} ${BACKUP_DIR}/${LOG_NAME}_${TIMESTAMP}.log
gzip ${BACKUP_DIR}/${LOG_NAME}_${TIMESTAMP}.log
touch ${LOG_FILE}
echo "Log rotation completed."
