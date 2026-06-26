#!/usr/bin/env bash
set -e
URL="https://emersonspartz.github.io/grixis-reanimator-sb-guide/"
html=$(curl -sf "$URL")
for needle in "JPA" "BEEFYGG" "Battlechads" "Discord" "postboard.gg" "Into the Flood Maw"; do
  grep -q "$needle" <<< "$html" || { echo "FAIL: missing '$needle'"; exit 1; }
done
# Regression test for the 2026-06-26 HTML-structure bug:
# matchup count must equal mu-body count (otherwise orphaned content)
mus=$(grep -c '<div class="mu\(\s\+open\)\?">' <<< "$html")
bodies=$(grep -c '<div class="mu-body">' <<< "$html")
[ "$mus" = "$bodies" ] || { echo "FAIL: mu/body mismatch ($mus vs $bodies) — structural bug regressed"; exit 1; }
echo "PASS: all strings present + mu/body balanced ($mus each)"
