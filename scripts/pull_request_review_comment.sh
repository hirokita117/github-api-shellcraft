#!/bin/bash

source "$(dirname "$0")/env.sh"

usage() {
    echo "Usage: $0 PR_NUMBER"
    echo "Example: $0 1000"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

PR_NUMBER="$1"

# Validate PR number
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid pull request number. Please provide a positive integer."
    echo -e -n "\\n"
    usage
fi


gh api \
    -H "Accept: application/vnd.github.v3+json" \
    "/repos/${GITHUB_OWNER}/${GITHUB_REPO}/pulls/${PR_NUMBER}/reviews" \
    --paginate \
    | jq '
        .[]
        | {
            id,
            user: .user.login,
            state,
            submitted_at,
            body
        }
    '
