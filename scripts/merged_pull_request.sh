#!/bin/bash

source "$(dirname "$0")/env.sh"

usage() {
    echo "Usage: $0 START_DATE END_DATE"
    echo "Example: $0 2021-01-01 2021-12-31"
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

START_DATE=$1
END_DATE=$2

DATE_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
if ! [[ $START_DATE =~ $DATE_REGEX ]] || ! [[ $END_DATE =~ $DATE_REGEX ]]; then
    echo "Error: invalid date format; use YYYY-MM-DD format."
    echo -e -n "\\n"
    usage
fi

gh pr list --limit 1000 --repo "$GITHUB_OWNER/$GITHUB_REPO" --state merged --json number --search "merged:$START_DATE..$END_DATE" | \
    jq -r '[.[].number] | join(",")'
