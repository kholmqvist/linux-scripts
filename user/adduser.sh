#!/bin/bash

while getopts ":n:" opt; do
    case ${opt} in
        n) USERNAME="${OPTARG}" ;;
        \?) echo "Invalid option: -${OPTARG}" >&2
            exit 1 ;;
        :) echo "Option -${OPTARG} requires an argument." >&2
            exit 1 ;;
    esac
done

# Add a new user
sudo useradd -m ${USERNAME}
sudo passwd ${USERNAME}
sudo usermod -aG sudo ${USERNAME}
echo "User ${USERNAME} added and granted sudo privileges."
