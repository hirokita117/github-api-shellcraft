#!/bin/bash

# GitHub Personal Access Token
export GITHUB_TOKEN="your_personal_access_token_here"

# Default repository owner and repository name
export GITHUB_OWNER="github_ownername"
export GITHUB_REPO="repository_name"

# Other settings
export GITHUB_SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Confirm that environment variables are set correctly
echo "Environment variables have been set:"
echo "GITHUB_OWNER: $GITHUB_OWNER"
echo "GITHUB_REPO: $GITHUB_REPO"
echo "GITHUB_SCRIPTS_DIR: $GITHUB_SCRIPTS_DIR"
echo -e -n "\\n"
echo "Script start!"
echo -e -n "\\n"
