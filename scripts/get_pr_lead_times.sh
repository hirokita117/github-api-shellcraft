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
echo "PR URL,Last Approve Time,Master Merge Time"

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
        echo "https://github.com/$REPO/pull/$PR_NUMBER,Not merged,Not merged" # Output in CSV format
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
        continue  # Skip this PR as there is no relase.
    fi

    MASTER_MERGE_TIME=$(gh pr view $RELEASE_PULL_REQUEST_NUMBER --repo $REPO --json mergedAt --jq .mergedAt)

    # Output in CSV format
    echo "https://github.com/$REPO/pull/$PR_NUMBER,$LAST_APPROVE_TIME,$MASTER_MERGE_TIME"
done

# Print skipped approval PR
echo -e -n "\\n"
echo "Skipped approval PR:"
for PR in "${SKIPPED_PRS[@]}"; do
    echo "https://github.com/$REPO/pull/$PR"
done
