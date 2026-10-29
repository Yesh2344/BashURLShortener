#!/usr/bin/env bash
# main.sh – CLI entry point for BashURLShortener

set -euo pipefail

# Load configuration and logger early
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Load core functions
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/shortener.sh"

print_help() {
    cat <<'EOF'
BashURLShortener – Command line interface

Usage:
  ./main.sh <command> [arguments]

Commands:
  shorten <url>      Create a short link for the given URL.
  expand <code>      Retrieve the original URL for a short code.
  list               Show all stored short URLs.
  delete <code>      Remove a short code from the database.
  help               Show this help message.

Examples:
  ./main.sh shorten https://example.com/long/path
  ./main.sh expand abc123
  ./main.sh list
  ./main.sh delete abc123
EOF
    exit 0
}

# Ensure at least one argument
if (( $# == 0 )); then
    print_help
fi

COMMAND="$1"
shift || true

case "${COMMAND}" in
    shorten)
        if (( $# != 1 )); then
            echo "Error: shorten requires exactly one URL argument." >&2
            exit 1
        fi
        shorten_url "$1"
        ;;
    expand)
        if (( $# != 1 )); then
            echo "Error: expand requires exactly one code argument." >&2
            exit 1
        fi
        expand_url "$1"
        ;;
    list)
        if (( $# != 0 )); then
            echo "Error: list takes no arguments." >&2
            exit 1
        fi
        list_urls
        ;;
    delete)
        if (( $# != 1 )); then
            echo "Error: delete requires exactly one code argument." >&2
            exit 1
        fi
        delete_url "$1"
        ;;
    help|-h|--help)
        print_help
        ;;
    *)
        echo "Error: Unknown command '${COMMAND}'." >&2
        print_help
        ;;
esac