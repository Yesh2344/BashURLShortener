#!/usr/bin/env bash
# test_shortener.sh – Basic integration tests for BashURLShortener

set -euo pipefail

# Load the library (functions) directly
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/shortener.sh"

# Use a temporary database for testing
export DB_PATH="$(mktemp -t shortener_test_XXXXXX.db)"
export LOG_FILE="/dev/null"
export BASE_URL="http://test.local"
export CODE_LENGTH=6

# Clean up after tests
cleanup() {
    rm -f "${DB_PATH}"
}
trap cleanup EXIT

# Initialise DB
init_db

# Helper assertion function
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    if [[ "${expected}" != "${actual}" ]]; then
        echo "FAIL: ${message}"
        echo "  Expected: ${expected}"
        echo "  Got     : ${actual}"
        exit 1
    else
        echo "PASS: ${message}"
    fi
}

# Test 1: Shorten a valid URL
SHORT_URL=$(shorten_url "https://example.com/path")
assert_equals 0 $? "shorten_url should succeed"
[[ "${SHORT_URL}" =~ ^http://test\.local/[a-zA-Z0-9]{6}$ ]] || {
    echo "FAIL: Short URL format invalid: ${SHORT_URL}"
    exit 1
}
CODE="${SHORT_URL##*/}"
echo "Generated code: ${CODE}"

# Test 2: Expand the previously generated code
EXPANDED=$(expand_url "${CODE}")
assert_equals "https://example.com/path" "${EXPANDED}" "expand_url returns original URL"

# Test 3: List should contain exactly one entry
LIST_OUTPUT=$(list_urls)
# Expect header + one row
# cleaner this way
EXPECTED_ROWS=2
ACTUAL_ROWS=$(echo "${LIST_OUTPUT}" | wc -l)
assert_equals "${EXPECTED_ROWS}" "${ACTUAL_ROWS}" "list_urls returns one mapping"

# Test 4: Delete the code
DELETE_OUTPUT=$(delete_url "${CODE}")
assert_equals "Deleted code ${CODE}." "${DELETE_OUTPUT}" "delete_url reports success"

# Test 5: Expanding after deletion should fail
if expand_url "${CODE}" >/dev/null 2>&1; then
    echo "FAIL: expand_url should have failed after deletion"
    exit 1
else
    echo "PASS: expand_url correctly failed after deletion"
fi

echo "All tests passed."