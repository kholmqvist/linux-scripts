#!/bin/bash

# Check if this server is a new clone
if [ -f "${HOME}/.first-boot" ]; then exit; fi

# Check if we are running as root
if [ "$(whoami)" == "root" ]; then echo "Don't run this script as root"; exit; fi

#Set Hostname
echo "Please set a new hostname!"
echo -n "New Hostname: "
read NAME
bash ${HOME}/NP-Linux-Scripts/hostname/set-hostname.sh -n ${NAME}


#Reset SSH-Keys
sudo rm /etc/ssh/ssh_host_*_key* 2>&1
ssh-keygen -q -N "" -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
sudo systemctl restart ssh

# Run this command as the last command before exiting
touch $HOME/.first-boot > /dev/null 2>&1
