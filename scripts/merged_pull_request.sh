#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Construct the path to common.sh in the parent directory
COMMON_FILE="$(dirname "$SCRIPT_DIR")/common.sh"

# Source the common functions
if [ -f "$COMMON_FILE" ]; then
    source "$COMMON_FILE"
else
    echo "Error: $COMMON_FILE not found" >&2
    exit 1
fi

# Load the environment variables
if ! load_env; then
    echo "Failed to load environment variables"
    exit 1
fi

START_DATE=$1
END_DATE=$2

DATE_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
if ! [[ $START_DATE =~ $DATE_REGEX ]] || ! [[ $END_DATE =~ $DATE_REGEX ]]; then
    echo "Error: invalid date format; use YYYY-MM-DD format."
    exit 1
fi

gh pr list --limit 1000 --repo "$GITHUB_OWNER/$GITHUB_REPO" --state merged --json number --search "merged:$START_DATE..$END_DATE" | \
    jq -r '[.[].number] | join(",")'
