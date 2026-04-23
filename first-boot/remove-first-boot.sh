#!/bin/bash

set -euo pipefail

if [ ! -f "${HOME}/.first-boot" ]; then
  echo "Error: First-boot lockfile not found. Has first-boot.sh been run?" >&2
  exit 1
fi

if ! rm -f "${HOME}/.first-boot"; then
  echo "Error: Failed to remove first-boot lockfile" >&2
  exit 1
fi

echo "First-boot lockfile removed successfully."
