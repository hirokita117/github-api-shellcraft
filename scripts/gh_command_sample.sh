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

# Check GitHub CLI authentication
if ! gh auth status &>/dev/null; then
    echo "GitHub CLI authentication is required. Please run the following command:"
    echo "gh auth login"
    exit 1
fi

# Fetch the list of issues for the repository
echo "List of issues for repository ${GITHUB_OWNER}/${GITHUB_REPO}:"
gh issue list -R "${GITHUB_OWNER}/${GITHUB_REPO}"
