#!/bin/bash

while getopts ":n:" opt; do
    case ${opt} in
				n) SERVICE="${OPTARG}" ;;
        \?) echo "Invalid option: -${OPTARG}" >&2
            exit 1 ;;
        :) echo "Option -${OPTARG} requires an argument." >&2
            exit 1 ;;
    esac
done

# Check the status of a specific service 
systemctl is-active --quiet ${SERVICE} && echo "${SERVICE} is running" || echo "${SERVICE} is not running"

