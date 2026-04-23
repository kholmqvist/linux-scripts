#!/bin/bash

set -euo pipefail

DOMAIN=""
PORT="443"

while getopts ":d:p:" opt; do
  case ${opt} in
    d) DOMAIN="${OPTARG}" ;;
    p) PORT="${OPTARG}" ;;
    \?) echo "Invalid option: -${OPTARG}" >&2
        exit 1 ;;
    :) echo "Option -${OPTARG} requires an argument." >&2
       exit 1 ;;
  esac
done

if [ -z "${DOMAIN}" ]; then
  echo "Error: Domain (-d) is required" >&2
  exit 1
fi

# Check SSL certificate expiration
EXPIRY_DATE=$(echo | openssl s_client -servername "${DOMAIN}" -connect "${DOMAIN}:${PORT}" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep notAfter | cut -d= -f2 || true)

if [ -z "${EXPIRY_DATE}" ]; then
  echo "Error: Unable to retrieve certificate for ${DOMAIN}:${PORT}" >&2
  exit 1
fi

# Convert expiry date to seconds since epoch (handle both GNU and BSD date)
if date --version >/dev/null 2>&1; then
  # GNU date (Linux)
  EXPIRY_EPOCH=$(date -d "${EXPIRY_DATE}" +%s)
else
  # BSD date (macOS)
  EXPIRY_EPOCH=$(date -jf "%b %d %T %Y %Z" "${EXPIRY_DATE}" +%s)
fi

CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

if [ "${DAYS_LEFT}" -lt 0 ]; then
  echo "Error: Certificate for ${DOMAIN} has already expired!" >&2
  exit 1
fi

if [ "${DAYS_LEFT}" -lt 30 ]; then
  echo "WARNING: SSL certificate for ${DOMAIN} expires in ${DAYS_LEFT} days (less than 30 days)" >&2
fi

echo "SSL certificate for ${DOMAIN} expires in ${DAYS_LEFT} days."
