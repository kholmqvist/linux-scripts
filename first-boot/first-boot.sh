#!/bin/bash

# Check if this server is a new clone
if [ -f "${HOME}/.first-boot" ]; then exit; fi

# Check if we are running as root
if [ "$(whoami)" == "root" ]; then echo "Don't run this script as root"; exit; fi

#Set Hostname
echo "Please set a new hostname!"
echo -n "New Hostname: "
read NAME
bash ${HOME}/NP-Linux/Scripts/set-hostname.sh -n ${NAME}

# Run this command as the last command before exiting
touch $HOME/.first-boot > /dev/null 2>&1
