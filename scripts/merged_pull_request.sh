#!/bin/bash

source "$(dirname "$0")/env.sh"

START_DATE=$1
END_DATE=$2

DATE_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
if ! [[ $START_DATE =~ $DATE_REGEX ]] || ! [[ $END_DATE =~ $DATE_REGEX ]]; then
    echo "Error: invalid date format; use YYYY-MM-DD format."
    exit 1
fi

gh pr list --limit 1000 --repo "$GITHUB_OWNER/$GITHUB_REPO" --state merged --json number --search "merged:$START_DATE..$END_DATE" | \
    jq -r '[.[].number] | join(",")'
