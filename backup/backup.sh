#!/bin/bash

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

# Backup a directory and store it in a backup folder with a timestamp
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
tar -czvf ${DEST}/${NAME}_backup_${TIMESTAMP}.tar.gz ${SOURCE}
echo "Backup completed: ${DEST}/${NAME}_backup_${TIMESTAMP}.tar.gz"
