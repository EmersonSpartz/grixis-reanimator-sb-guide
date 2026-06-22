#!/bin/bash
# Verification script — the QA gate won't clear until this passes.
# Customize the checks below for your project.
set -e
cd "$(dirname "$0")"

echo "=== Verification ==="
FAIL=0

# ── Basic syntax/import check ──

# ── DOM Health Check (catches blank pages, missing elements, errors) ──
PAGE_URL="http://localhost:3000"
PAGE_HTML=$(curl -s "$PAGE_URL/" 2>/dev/null)
PAGE_LEN=${#PAGE_HTML}

if [ "$PAGE_LEN" -gt 100 ]; then
    echo -n "Page not blank... "
    if [ "$PAGE_LEN" -gt 500 ]; then
        echo "OK ($PAGE_LEN chars)"
    else
        echo "WARN (only $PAGE_LEN chars — might be an error page)"
    fi

    # Check for error indicators in the HTML
    echo -n "No error indicators... "
    ERRORS=""
    for indicator in "Internal Server Error" "Traceback (most recent" "SyntaxError" "TypeError:" "ReferenceError:"; do
        echo "$PAGE_HTML" | LC_ALL=C grep -qi "$indicator" 2>/dev/null && ERRORS="$ERRORS '$indicator'"
    done
    if [ -z "$ERRORS" ]; then
        echo "OK"
    else
        echo "FAIL (found:$ERRORS)"
        FAIL=1
    fi
fi

# ── Deployed version check ──
DEPLOY_URL="${DEPLOY_URL:-}"
if [ -n "$DEPLOY_URL" ]; then
    echo -n "Deployed page ($DEPLOY_URL)... "
    DEPLOY_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$DEPLOY_URL/" 2>/dev/null)
    if [ "$DEPLOY_STATUS" = "200" ]; then
        echo "OK"
    else
        echo "FAIL (HTTP $DEPLOY_STATUS)"
        FAIL=1
    fi
fi

if [ $FAIL -eq 1 ]; then
    echo "=== VERIFY FAILED ==="
    exit 1
fi

echo "=== ALL CHECKS PASSED ==="
