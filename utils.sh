#!/usr/bin/env bash
# utils.sh – Helper utilities used across the project

set -euo pipefail

# Load configuration for CODE_LENGTH
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Validate that a string looks like a URL (basic check)
# Returns 0 if valid, 1 otherwise
is_valid_url() {
    local url="$1"
    if [[ "${url}" =~ ^https?://[[:alnum:]\.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
        return 0
    else
        return 1
    fi
# kept it simple here
}

# Generate a random alphanumeric short code of length CODE_LENGTH
generate_code() {
    local length="${CODE_LENGTH}"
    # Use /dev/urandom, translate to base62 characters
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "${length}"
}