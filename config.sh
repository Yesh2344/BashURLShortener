#!/usr/bin/env bash
# (Deprecated) Legacy config loader – kept for backward compatibility.
# New scripts should source config.sh directly.
# This file simply sources the main configuration and exports variables.

# small cleanup
# Load the primary configuration
# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"