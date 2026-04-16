#!/bin/bash

# This script automates the process of updating 'variables.tf' with new options
# from the RKE2 binary. It performs the following steps:
#
# 1. Fetches the latest CLI options from the 'rke2-helper' Docker image.
# 2. Parses the existing variable names from the 'variables.tf' file.
# 3. Compares the two lists to find options that are missing from the file.
# 4. Generates new Terraform 'variable' blocks for each missing option.
# 5. Appends the new blocks to the end of 'variables.tf'.
#
# After running, you should manually review the appended variables to ensure
# the inferred types and validations are correct, and add source code links
# as per the project's contribution guidelines in 'variables.md'.

set -euo pipefail

# --- Default Configuration ---
VARIABLES_FILE="variables.tf"
RKE2_HELPER_IMAGE="rke2-helper"
JSON_PARSER_SCRIPT="./helptojson.sh"
DRY_RUN=false

# --- Argument Parsing ---
while getopts "d" opt; do
  case $opt in
    d)
      DRY_RUN=true
      ;;
    \?)
      echo "Usage: cmd [-d]" >&2
      exit 1
      ;;
  esac
done

# --- Prerequisite Checks ---
if ! command -v docker &> /dev/null; then
    echo "Error: The 'docker' command is not available. Please ensure it's installed and in your PATH." >&2
    exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "Error: The 'jq' command is not available. Please install it (e.g., 'brew install jq')." >&2
    exit 1
fi
if [ ! -f "$VARIABLES_FILE" ]; then
    echo "Error: The file '$VARIABLES_FILE' was not found in the current directory." >&2
    exit 1
fi
if [ ! -x "$JSON_PARSER_SCRIPT" ]; then
    echo "Error: The script '$JSON_PARSER_SCRIPT' is not executable or not found." >&2
    exit 1
fi


# --- Main Logic ---

echo "Step 1: Fetching latest RKE2 release version from GitHub..."
# Use GITHUB_TOKEN if available to avoid rate limiting
auth_header=()
if [ -n "$GITHUB_TOKEN" ]; then
  auth_header=("-H" "Authorization: Bearer $GITHUB_TOKEN")
fi
RKE2_VERSION=$(curl -s "${auth_header[@]}" https://api.github.com/repos/rancher/rke2/releases/latest | jq -r .tag_name)

if [ -z "$RKE2_VERSION" ] || [ "$RKE2_VERSION" == "null" ]; then
    echo "Error: Failed to fetch latest RKE2 release version from GitHub." >&2
    exit 1
fi
echo "  - Found latest version: $RKE2_VERSION"

echo "Step 2: Building '$RKE2_HELPER_IMAGE' for RKE2 version '$RKE2_VERSION'..."
docker build --build-arg "RKE2_VERSION=${RKE2_VERSION}" -t "$RKE2_HELPER_IMAGE" . > /dev/null

echo "Step 3: Generating current RKE2 options from the container..."
# Get all options and descriptions from the helper container as a JSON object.
# Use jq to ensure it's valid JSON before proceeding.
all_options_json=$(docker run --rm "$RKE2_HELPER_IMAGE" | "$JSON_PARSER_SCRIPT" | jq '.')

if [ -z "$all_options_json" ]; then
    echo "Error: Failed to generate JSON from rke2-helper." >&2
    exit 1
fi
# Get just the keys (option names) from the JSON, sorted.
# Exclude the 'config' option as it is not a valid key in the config file itself.
rke2_options=$(echo "$all_options_json" | jq -r '. | keys_unsorted[]' | grep -v -E '^config$' | sort)

echo "Step 4: Parsing existing variables from '$VARIABLES_FILE'..."
# Extract existing variable names from variables.tf, sorted.
# This regex is specific to the format 'variable "name" {'.
# Exclude module-specific variables that are not part of the RKE2 config.
tf_variables=$(grep '^variable ' "$VARIABLES_FILE" | sed -E 's/variable "([^"]+)".*/\1/' | grep -v -E '^(local_file_path|local_file_name)$' | sort)

echo "Step 5: Finding missing options..."
# Use `comm` to find lines that are in rke2_options but not in tf_variables.
missing_options=$(comm -23 <(echo "$rke2_options") <(echo "$tf_variables"))

echo "Step 6: Finding deprecated options..."
# Use `comm` to find lines that are in tf_variables but not in rke2_options.
deprecated_options=$(comm -13 <(echo "$rke2_options") <(echo "$tf_variables"))

if [ -z "$missing_options" ] && [ -z "$deprecated_options" ]; then
    echo "Success: '$VARIABLES_FILE' is already up-to-date. No changes needed."
    exit 0
fi

if [ -n "$deprecated_options" ]; then
    echo
    echo "--- DEPRECATED OPTIONS DETECTED ---"
    echo "The following options exist in '$VARIABLES_FILE' but are no longer in the RKE2 CLI:"
    echo "$deprecated_options"
    echo "Please review and consider removing them manually."
fi

if [ -n "$missing_options" ]; then
    echo
    echo "Step 7: Generating Terraform blocks for missing options..."
    new_blocks=""
    while IFS= read -r option; do
        echo "  - Found missing option: $option"
        description=$(echo "$all_options_json" | jq -r --arg key "$option" '.[$key]')

        # Generate GitHub search URLs for k3s and rke2.
        # This provides a deep link to search for the option in the relevant source file.
        k3s_query="repo:k3s-io/k3s path:pkg/cli/cmds/server.go ${option}"
        k3s_query_encoded=$(echo -n "$k3s_query" | jq -Rr @uri)
        k3s_search_url="https://github.com/search?q=${k3s_query_encoded}&type=code"

        rke2_query="repo:rancher/rke2 path:pkg/cli/cmds/server.go ${option}"
        rke2_query_encoded=$(echo -n "$rke2_query" | jq -Rr @uri)
        rke2_search_url="https://github.com/search?q=${rke2_query_encoded}&type=code"

        # Assemble a basic skeleton block. Manual review is required for type
        # inference, validation logic, and finding the specific line number for the source link.
        block=$(cat <<-EOM
# k3s: ${k3s_search_url}
# rke2: ${rke2_search_url}
# Type(?):
variable "$option" {
  type        = string
  description = <<-EOT
    $description
  EOT
  default     = null
}
EOM
)
        new_blocks+="$block\n\n"
    done <<< "$missing_options"

    if [ "$DRY_RUN" = true ]; then
        echo
        echo "--- DRY RUN: Missing Options ---"
        echo "The following blocks would be generated (but not appended):"
        echo -e "$new_blocks"
    else
        echo "Step 8: Appending new blocks to '$VARIABLES_FILE'..."
        printf "\n%b" "$new_blocks" >> "$VARIABLES_FILE"

        echo "Success! Added the following options to '$VARIABLES_FILE':"
        echo "$missing_options"
        echo
        echo "IMPORTANT: Please review the generated blocks at the end of '$VARIABLES_FILE'."
        echo "You will need to manually adjust types (e.g., to list(string)) and add validation blocks."
    fi
fi
