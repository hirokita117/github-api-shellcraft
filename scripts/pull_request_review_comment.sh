#!/bin/bash

source "$(dirname "$0")/env.sh"

PR_NUMBER="$1"

# Validate PR number
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid pull request number. Please provide a positive integer."
    exit 1
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
