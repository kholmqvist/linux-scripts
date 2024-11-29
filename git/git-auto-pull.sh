#!/bin/bash

while getopts ":d:" opt; do
  case ${opt} in
    d) REPO_PATH="${OPTARG}" ;;
    \?) echo "Invalid option: -${OPTARG}" >&2
        exit 1 ;;
    :) echo "Option -${OPTARG} requires an argument." >&2
        exit 1 ;;
  esac
done

# Auto pull the latest code from the Git repository
BRANCH="main"
cd ${REPO_PATH}
git pull origin ${BRANCH}
echo "Code pulled from ${BRANCH} branch."
