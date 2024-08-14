#!/bin/bash

# Load environment variables
source "$(dirname "$0")/env.sh"

# Check GitHub CLI authentication
if ! gh auth status &>/dev/null; then
    echo "GitHub CLI authentication is required. Please run the following command:"
    echo "gh auth login"
    exit 1
fi

# Fetch the list of issues for the repository
echo "List of issues for repository ${GITHUB_OWNER}/${GITHUB_REPO}:"
gh issue list -R "${GITHUB_OWNER}/${GITHUB_REPO}"
