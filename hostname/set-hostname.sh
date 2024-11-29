#!/bin/bash

while getopts ":n:" opt; do
  case ${opt} in
	  n) NAME="${OPTARG}" ;;
    \?) echo "Invalid option: -${OPTARG}" >&2
        exit 1 ;;
    :) echo "Option -${OPTARG} requires an argument." >&2
        exit 1 ;;
  esac
done

sudo hostnamectl hostname ${NAME}
