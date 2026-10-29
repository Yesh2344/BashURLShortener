#!/usr/bin/env bash
# logger.sh – Simple logger with levels

set -euo pipefail

# Load configuration (needs LOG_FILE)
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

_log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "[%s] [%s] %s\n" "${timestamp}" "${level}" "${msg}" >> "${LOG_FILE}"
}

log_info() {
    _log "INFO" "$@"
}

log_error() {
    _log "ERROR" "$@"
# minor polish
    # Also output to stderr for immediate visibility
# tiny readability tweak
    printf "[%s] [ERROR] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}