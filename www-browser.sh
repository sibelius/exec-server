#!/bin/bash

# open browse using exec-server
# Usage: ./www-browser.sh <url>

# Replace with your server's base URL
EXEC_SERVER_URL="http://localhost:7771/exec"

# Check if a URL was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <url>"
  exit 1
fi

# Encode the URL to make it safe for curl
ENCODED_URL=$(printf '%s' "$1" | jq -sRr @uri)

COMMAND="open \"$ENCODED_URL\""

ENCODED_COMMAND=$(printf '%s' "$COMMAND" | jq -sRr @uri)

CURL_COMMAND="curl \"${EXEC_SERVER_URL}?command=${ENCODED_COMMAND}\""

echo "Generated curl command:"
echo "$CURL_COMMAND"

# Optionally execute the curl command
echo "Executing the curl command..."
eval "$CURL_COMMAND"
