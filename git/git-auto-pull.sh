#!/bin/bash

set -euo pipefail

REPO_PATH=""
BRANCH="main"

while getopts ":d:b:" opt; do
  case ${opt} in
    d) REPO_PATH="${OPTARG}" ;;
    b) BRANCH="${OPTARG}" ;;
    \?) echo "Invalid option: -${OPTARG}" >&2
        exit 1 ;;
    :) echo "Option -${OPTARG} requires an argument." >&2
        exit 1 ;;
  esac
done

# Validate required argument
if [ -z "${REPO_PATH}" ]; then
  echo "Error: Repository path (-d) is required" >&2
  exit 1
fi

# Validate repository path exists
if [ ! -d "${REPO_PATH}" ]; then
  echo "Error: Repository path not found: ${REPO_PATH}" >&2
  exit 1
fi

# Validate it's a git repository
if [ ! -d "${REPO_PATH}/.git" ]; then
  echo "Error: Not a git repository: ${REPO_PATH}" >&2
  exit 1
fi

# Change to repository directory
if ! cd "${REPO_PATH}"; then
  echo "Error: Cannot change to repository directory: ${REPO_PATH}" >&2
  exit 1
fi

# Validate git pull succeeds
if ! git pull origin "${BRANCH}"; then
  echo "Error: Git pull from ${BRANCH} failed" >&2
  exit 1
fi

echo "Code pulled from ${BRANCH} branch successfully."
