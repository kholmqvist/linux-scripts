#!/bin/bash

set -euo pipefail

# Check if this server is a new clone
if [ -f "${HOME}/.first-boot" ]; then
  echo "First boot has already been completed. Run remove-first-boot.sh to reset." >&2
  exit 0
fi

# Check if we are running as root
if [ "$(whoami)" == "root" ]; then
  echo "Error: Don't run this script as root" >&2
  exit 1
fi

# Set Hostname
echo "Please set a new hostname!"
echo -n "New Hostname: "
read -r NAME

if [ -z "${NAME}" ]; then
  echo "Error: Hostname cannot be empty" >&2
  exit 1
fi

if ! bash "${HOME}/NP-Linux-Scripts/hostname/set-hostname.sh" -n "${NAME}"; then
  echo "Error: Failed to set hostname" >&2
  exit 1
fi

# Reset SSH-Keys
echo "Generating new SSH host keys..."
if ! sudo rm -f /etc/ssh/ssh_host_*_key* 2>&1; then
  echo "Error: Failed to remove old SSH keys" >&2
  exit 1
fi

if ! ssh-keygen -q -N "" -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key; then
  echo "Error: Failed to generate RSA key" >&2
  exit 1
fi

if ! ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key; then
  echo "Error: Failed to generate ECDSA key" >&2
  exit 1
fi

if ! ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key; then
  echo "Error: Failed to generate Ed25519 key" >&2
  exit 1
fi

if ! sudo systemctl restart ssh; then
  echo "Error: Failed to restart SSH service" >&2
  exit 1
fi

# Run this command as the last command before exiting
if ! touch "${HOME}/.first-boot"; then
  echo "Error: Failed to create first-boot lockfile" >&2
  exit 1
fi

echo "First boot setup completed successfully."
