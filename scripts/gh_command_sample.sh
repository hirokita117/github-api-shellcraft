#!/bin/bash

source "$(dirname "$0")/env.sh"

# Fetch the list of issues for the repository
echo "List of issues for repository ${GITHUB_OWNER}/${GITHUB_REPO}:"
gh issue list -R "${GITHUB_OWNER}/${GITHUB_REPO}"
