#!/bin/bash

set -euo pipefail

# Check disk usage and send alert if usage exceeds 80%
THRESHOLD=80

if ! command -v df &> /dev/null; then
  echo "Error: df command not found" >&2
  exit 1
fi

df -h | awk -v threshold="${THRESHOLD}" '$5+0 > threshold {print $0}' | while read -r output; do
  if [ -n "${output}" ]; then
    echo "Disk usage alert: ${output}"
  fi
done
