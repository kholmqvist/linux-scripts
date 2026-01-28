#!/bin/bash
KNOWN="/tmp/known_ips.txt"
ss -tunp | awk '{print $6}' > $KNOWN
while true; do
  CURRENT=$(mktemp)
  ss -tunp | awk '{print $6}' > $CURRENT
  diff $KNOWN $CURRENT | grep '>' && echo "[ALERT] New outbound connection detected!"
  mv $CURRENT $KNOWN
  sleep 30
done
