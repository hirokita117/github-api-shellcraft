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
