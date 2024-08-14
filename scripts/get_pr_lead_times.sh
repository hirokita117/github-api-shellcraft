#!/bin/bash

source "$(dirname "$0")/env.sh"

# Function to display usage
usage() {
    echo "Usage: $0 <PR_NUMBER1>[,PR_NUMBER2,...]"
    echo "Example: $0 1347,1348,1349"
    exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
    usage
fi

REPO="$GITHUB_OWNER/$GITHUB_REPO"
PR_NUMBERS=$(echo $1 | tr ',' ' ')

# Array to store skipped PR numbers
SKIPPED_PRS=()

# Print CSV header
echo "PR URL,Last Approve Time,Merge Time"

for PR_NUMBER in $PR_NUMBERS; do
    # Get PR details
    PR_DETAILS=$(gh api repos/$REPO/pulls/$PR_NUMBER --jq '{mergedAt: .merged_at, number: .number, base: .base.ref, head: .head.ref}')

    # Check if PR is from develop to master
    BASE_BRANCH=$(echo $PR_DETAILS | jq -r .base)
    HEAD_BRANCH=$(echo $PR_DETAILS | jq -r .head)
    
    if [ "$BASE_BRANCH" = "master" ] && [ "$HEAD_BRANCH" = "develop" ]; then
        continue  # Skip this PR as it's a develop to master merge
    fi

    # If PR is not merged, display error and continue to next PR
    if [ -z "$PR_DETAILS" ] || [ "$(echo $PR_DETAILS | jq -r .mergedAt)" = "null" ]; then
        echo "$PR_NUMBER,Not merged,Not merged" # Output in CSV format
        continue
    fi

    PR_NUMBER=$(echo $PR_DETAILS | jq -r .number)
    MERGED_AT=$(echo $PR_DETAILS | jq -r .mergedAt)

    # Get the last approve comment time
    LAST_APPROVE_TIME=$(gh api repos/$REPO/pulls/$PR_NUMBER/reviews --jq 'map(select(.state == "APPROVED")) | max_by(.submitted_at) | .submitted_at')

    if [ "$LAST_APPROVE_TIME" = "null" ] || [ "$LAST_APPROVE_TIME" = "" ]; then
        SKIPPED_PRS+=($PR_NUMBER)
        continue  # Skip this PR as there is no approve.
    fi

    # Output in CSV format
    echo "https://github.com/$REPO/pull/$PR_NUMBER,$LAST_APPROVE_TIME,$MERGED_AT"
done

# Print skipped approval PR
echo -e -n "\\n"
echo "Skipped approval PR:"
for PR in "${SKIPPED_PRS[@]}"; do
    echo "https://github.com/$REPO/pull/$PR"
done
