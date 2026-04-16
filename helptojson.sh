#!/bin/bash

# This script parses the output of `rke2 server --help` (provided via stdin)
# and generates a single JSON object of the form { "option": "description" }.
# It is designed to be more robust than the previous version by using a
# single, powerful awk command for parsing.
#
# Usage:
#   docker run --rm rke2-helper | ./helptojson.sh

set -euo pipefail

# Read the help output from stdin
help_output=$(cat)

# Use awk to parse the OPTIONS section and extract key-value pairs.
# Then use paste and sed to format it into a valid JSON object.
echo "$help_output" | \
awk '
    # Start processing after the OPTIONS: line
    /^OPTIONS:/ { in_options = 1; next }
 
    # Only process lines within the OPTIONS section that define a flag
    !in_options || !/^[[:space:]]+--/ { next }
 
    {
        # Find the first parenthesis to split flag from description.
        # The description always seems to start with a category like (db).
        paren_pos = match($0, /[[:space:]]+\(/)
        if (paren_pos == 0) {
            next
        }
 
        # --- Extract and clean the option name ---
        flag_part = substr($0, 1, paren_pos - 1)
        gsub(/^[[:space:]]+--/, "", flag_part)
        # Take only the first part before a comma or space (to handle aliases and "value")
        gsub(/,.*/, "", flag_part)
        gsub(/[[:space:]].*/, "", flag_part)
        option_name = flag_part
 
        # --- Extract and clean the description ---
        desc_part = substr($0, paren_pos)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc_part)
        gsub(/[[:space:]]+\[\$.*\]$/, "", desc_part)
        gsub(/\\/, "\\\\", desc_part)
        gsub(/"/, "\\\"", desc_part)
 
        # Print the JSON key-value pair
        print "\"" option_name "\": \"" desc_part "\""
    }
' | paste -sd, - | sed 's/^/{/; s/$/}/'
