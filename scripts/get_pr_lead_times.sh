#!/bin/bash

source "$(dirname "$0")/env.sh"

# Function to display usage
usage() {
    echo "Usage: $0 [-o] <PR_NUMBER1>[,PR_NUMBER2,...]"
    echo "Example: $0 -o 1347,1348,1349"
    echo "If the -o option is given, get_pr_lead_times.csv file is generated in the outputs/ directory."
    exit 1
}

# Function to output CSV
print_or_append_to_csv() {
    if [ "$CAN_OUTPUT_TO_FILE" = "true" ]; then
        echo "$1" >> "$OUTPUT_FILE"
    else
        echo "$1"
    fi
}

# Function to convert date to Unix timestamp
date_to_timestamp() {
    date -j -f "%Y-%m-%d %H:%M:%S" "$1" +%s
}

# Function to calculate time difference
calculate_time_difference() {
    local START_TIME=$(echo "$1" | sed 's/T/ /g; s/Z//g')
    local END_TIME=$(echo "$2" | sed 's/T/ /g; s/Z//g')
    local START_TIMESTAMP=$(date_to_timestamp "$START_TIME")
    local END_TIMESTAMP=$(date_to_timestamp "$END_TIME")

    echo $((END_TIMESTAMP - START_TIMESTAMP))
}

# Function to format seconds to HH:MM:SS
format_time() {
    local TOTAL_SECONDS=$1
    local HOURS=$((TOTAL_SECONDS / 3600))
    local MINUTES=$(( (TOTAL_SECONDS % 3600) / 60 ))
    local SECONDS=$((TOTAL_SECONDS % 60))

    printf "%02d:%02d:%02d\n" $HOURS $MINUTES $SECONDS
}

# Initialize variables
CAN_OUTPUT_TO_FILE=false
ROOT_DIR="$(dirname "$GITHUB_SCRIPTS_DIR")"
OUTPUT_DIR="$ROOT_DIR/outputs"
OUTPUT_FILE="$OUTPUT_DIR/get_pr_lead_times.csv"

# Parse command line options
while getopts ":o" opt; do
    case ${opt} in
    o )
        CAN_OUTPUT_TO_FILE=true
        ;;
    \? )
        echo "Invalid option: $OPTARG" 1>&2
        usage
        ;;
    esac
done
shift $((OPTIND -1))

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

REPO="$GITHUB_OWNER/$GITHUB_REPO"
PR_NUMBERS=$(echo $1 | tr ',' ' ')

# Array to store skipped PR numbers
SKIPPED_PRS=()

# Print CSV header
HEADER="PR URL,Last Approve Time,Master Merge Time,Lead Time"
if [ "$CAN_OUTPUT_TO_FILE" = "true" ]; then
    echo "$HEADER" > "$OUTPUT_FILE"
else
    echo "$HEADER"
fi

for PR_NUMBER in $PR_NUMBERS; do
    # Get PR details
    PR_DETAILS=$(gh api repos/$REPO/pulls/$PR_NUMBER --jq '{mergeCommit: .merge_commit_sha, number: .number, base: .base.ref, head: .head.ref}')

    # Check if PR is from develop to master
    BASE_BRANCH=$(echo $PR_DETAILS | jq -r .base)
    HEAD_BRANCH=$(echo $PR_DETAILS | jq -r .head)
    
    if [ "$BASE_BRANCH" = "master" ] && [ "$HEAD_BRANCH" = "develop" ]; then
        continue  # Skip this PR as it's a develop to master merge
    fi

    # If PR is not merged, display error and continue to next PR
    if [ -z "$PR_DETAILS" ] || [ "$(echo $PR_DETAILS | jq -r .mergeCommit)" = "null" ]; then
        print_or_append_to_csv "https://github.com/$REPO/pull/$PR_NUMBER,Not merged,Not merged,00:00:00"
        continue
    fi

    PR_NUMBER=$(echo $PR_DETAILS | jq -r .number)
    MERGE_COMMIT=$(echo $PR_DETAILS | jq -r .mergeCommit)

    # Get the last approve comment time
    LAST_APPROVE_TIME=$(gh api repos/$REPO/pulls/$PR_NUMBER/reviews --jq 'map(select(.state == "APPROVED")) | max_by(.submitted_at) | .submitted_at')

    if [ "$LAST_APPROVE_TIME" = "null" ] || [ "$LAST_APPROVE_TIME" = "" ]; then
        SKIPPED_PRS+=($PR_NUMBER)
        continue  # Skip this PR as there is no approve.
    fi

    RELEASE_PULL_REQUEST_NUMBER=$(gh pr list --repo $REPO --search $MERGE_COMMIT --state merged --base master --json number --jq '.[].number')

    if [ "$RELEASE_PULL_REQUEST_NUMBER" = "null" ] || [ "$RELEASE_PULL_REQUEST_NUMBER" = "" ]; then
        SKIPPED_PRS+=($PR_NUMBER)
        continue  # Skip this PR as there is no release.
    fi

    MASTER_MERGE_TIME=$(gh pr view $RELEASE_PULL_REQUEST_NUMBER --repo $REPO --json mergedAt --jq .mergedAt)

    DIFF=$(calculate_time_difference "$LAST_APPROVE_TIME" "$MASTER_MERGE_TIME")
    LEAD_TIME=$(format_time $DIFF)

    # Output in CSV format
    print_or_append_to_csv "https://github.com/$REPO/pull/$PR_NUMBER,$LAST_APPROVE_TIME,$MASTER_MERGE_TIME,$LEAD_TIME"
done

# Print skipped approval PR
echo -e -n "\\n"
echo "Skipped approval PR:"
for PR in "${SKIPPED_PRS[@]}"; do
    echo "https://github.com/$REPO/pull/$PR"
done

if [ "$CAN_OUTPUT_TO_FILE" = "true" ]; then
    echo -e -n "\\n"
    echo "Output saved to $OUTPUT_FILE"
fi
