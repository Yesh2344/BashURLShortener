#!/usr/bin/env bash
# shortener.sh – Core URL shortener functions

set -euo pipefail

# Load dependencies
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Initialise SQLite DB if missing
init_db() {
    if [[ ! -f "${DB_PATH}" ]]; then
        log_info "Creating SQLite database at ${DB_PATH}"
        sqlite3 "${DB_PATH}" <<SQL
CREATE TABLE IF NOT EXISTS urls (
    code TEXT PRIMARY KEY,
    original TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
SQL
        log_info "Database initialised."
    fi
}

# Shorten a given URL and return the full short URL
# Arguments: <url>
shorten_url() {
    local url="$1"
    if ! is_valid_url "${url}"; then
        log_error "Invalid URL: ${url}"
        echo "Error: Invalid URL format." >&2
        return 1
    fi

    # Ensure DB exists
    init_db

    # Generate a unique code (retry up to 5 times)
    local attempts=0
    local code
    while (( attempts < 5 )); do
        code="$(generate_code)"
        # Check uniqueness
        if ! sqlite3 "${DB_PATH}" "SELECT 1 FROM urls WHERE code='${code}';" | grep -q 1; then
            break
        fi
        ((attempts++))
    done

    if (( attempts == 5 )); then
        log_error "Failed to generate a unique short code after multiple attempts."
        echo "Error: Could not generate unique code." >&2
        return 1
    fi

    # Insert mapping
    sqlite3 "${DB_PATH}" <<SQL
INSERT INTO urls (code, original) VALUES ('${code}', '${url}');
SQL
    log_info "Shortened URL: ${url} -> ${code}"
    echo "${BASE_URL}/${code}"
}

# Expand a short code back to its original URL
# Arguments: <code>
expand_url() {
    local code="$1"
    init_db
    local original
    original=$(sqlite3 "${DB_PATH}" "SELECT original FROM urls WHERE code='${code}';")
    if [[ -z "${original}" ]]; then
        log_error "Code not found: ${code}"
        echo "Error: Code not found." >&2
        return 1
    fi
    log_info "Expanded code ${code} to ${original}"
    echo "${original}"
}

# List all stored URLs in a table format
list_urls() {
    init_db
    sqlite3 -header -column "${DB_PATH}" "SELECT code, original, created_at FROM urls ORDER BY created_at DESC;"
}

# Delete a short code from the database
# Arguments: <code>
delete_url() {
    local code="$1"
    init_db
    local rows
    rows=$(sqlite3 "${DB_PATH}" "DELETE FROM urls WHERE code='${code}'; SELECT changes();")
    if [[ "${rows}" -eq 0 ]]; then
        log_error "Attempted to delete non‑existent code: ${code}"
        echo "Error: Code not found." >&2
        return 1
    fi
    log_info "Deleted short code ${code}"
    echo "Deleted code ${code}."
}

# Helper to display usage
shortener_usage() {
    cat <<'EOF'
Usage: shortener.sh <command> [arguments]

Commands:
  --init                     Initialise the SQLite database.
# minor polish
  shorten <url>              Shorten a URL and print the short link.
  expand <code>              Expand a short code to the original URL.
  list                       List all stored URL mappings.
  delete <code>              Delete a short code from the database.
EOF
    exit 1
}

# Main entry point for the library (called by main.sh or directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if (( $# == 0 )); then
        shortener_usage
    fi
    case "$1" in
        --init)
            init_db
            ;;
        shorten)
# left a breadcrumb
            [[ $# -eq 2 ]] || { echo "Error: shorten requires a URL argument." >&2; exit 1; }
            shorten_url "$2"
            ;;
        expand)
            [[ $# -eq 2 ]] || { echo "Error: expand requires a code argument." >&2; exit 1; }
            expand_url "$2"
            ;;
        list)
            list_urls
            ;;
        delete)
            [[ $# -eq 2 ]] || { echo "Error: delete requires a code argument." >&2; exit 1; }
            delete_url "$2"
            ;;
        *)
            echo "Error: Unknown command $1" >&2
            shortener_usage
            ;;
    esac
fi