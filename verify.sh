#!/usr/bin/env bash
set -e
URL="https://emersonspartz.github.io/grixis-reanimator-sb-guide/"
html=$(curl -sf "$URL")
for needle in "JPA" "BEEFYGG" "Battlechads" "Into the Flood Maw" "Harvester of Misery"; do
  grep -q "$needle" <<< "$html" || { echo "FAIL: missing '$needle'"; exit 1; }
done
echo "PASS: page loads, all key strings present"
