#!/bin/bash

set -euo pipefail

# Docker container and image cleanup
if ! command -v docker &> /dev/null; then
  echo "Error: Docker command not found" >&2
  exit 1
fi

echo "Starting Docker cleanup..."
docker system prune -af || { echo "Error: Docker system prune failed" >&2; exit 1; }
docker volume prune -f || { echo "Error: Docker volume prune failed" >&2; exit 1; }
echo "Docker cleanup completed successfully."
