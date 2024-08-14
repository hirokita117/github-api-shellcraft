#!/bin/bash

# Function to load env.sh from the same directory as common.sh
load_env() {
    # Get the directory of this common.sh file
    local COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Construct the full path to env.sh in the same directory
    local ENV_FILE="$COMMON_DIR/env.sh"

    # Check if the env.sh file exists
    if [ -f "$ENV_FILE" ]; then
        echo "Loading environment variables from $ENV_FILE"
        source "$ENV_FILE"
    else
        echo "Error: $ENV_FILE not found" >&2
        return 1
    fi
}

# Add other common functions here if needed
