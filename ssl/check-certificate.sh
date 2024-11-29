#!/bin/bash

while getopts ":dp" opt; do
    case ${opt} in
        d) DOMAIN="${OPTARG}" ;;
				p) PORT="${OPTARG}" ;;
        \?) echo "Invalid option: -${OPTARG}" >&2
            exit 1 ;;
        :) echo "Option -${OPTARG} requires an argument." >&2
            exit 1 ;;
    esac
done

# Check SSL certificate expiration 
EXPIRY_DATE=$(echo | openssl s_client -servername ${DOMAIN} -connect ${DOMAIN}:${PORT:-443} 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2)
DAYS_LEFT=$(( ($(date -d "${EXPIRY_DATE}" +%s) - $(date +%s)) / 86400 ))
echo "SSL certificate for ${DOMAIN} expires in ${DAYS_LEFT} days."
