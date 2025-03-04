#!/bin/bash

help_output=$(rke2 help server | grep -- '--')

json_string=""

while IFS= read -r line
do
    name_type=$(echo "$line" | awk -F'(' '{ gsub(/^[ \t]+|[ \t]+$/, "",$1); gsub(/,/, "",$1); gsub(/--/,"",$1); print $1 }')
    description=$(echo "$line" | awk -F'(' '{ gsub(/^[ \t]+|[ \t]+$/, "", $2); print "("$2 }')

    IFS=' ' read -r name type <<< "$name_type"

    if [ -z "$type" ]; then
        type="bool"
    else
	type="string"
    fi

    json_string+="{\"name\":\"$name\", \"type\":\"$type\", \"description\":\"$description\"},"
done <<< "$help_output"

json_string=${json_string%?}  # Remove the trailing comma

# Convert JSON to Terraform variables
jq -c '.[]' <<< "[$json_string]" | while read -r i; do
    name=$(jq -r '.name' <<< "$i")
    type=$(jq -r '.type' <<< "$i")
    description=$(jq -r '.description' <<< "$i")

    # Remove environment variable indicators, as they are not valid in this context (and strip resulting whitespace).
    description=$(echo "$description" | sed 's/\[[^]]*\]//g' | sed 's/\s*$//')

    # Terraform descriptions need to be sentences, linter checks for a dot at the end, and a capital letter at the beginning.
    description=$(if [[ "$description" == *"." ]]; then echo "$description"; else echo "$description."; fi)
    # shellcheck disable=SC2001
    description=$(echo "$description" | sed 's/\b\(.\)/\u\1/')

    echo "variable \"$name\" {"
    echo "  type = \"$type\""
    echo "  description = <<-EOT"
    echo "    $description"
    echo "  EOT"
    echo "  default = \"\""
    echo "}"
    echo ""
done
