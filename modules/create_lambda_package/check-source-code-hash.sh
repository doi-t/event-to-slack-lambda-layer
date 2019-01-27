#!/bin/bash
# Ref. https://www.terraform.io/docs/providers/external/data_source.html

# Exit if any of the intermediate steps fail
set -ex

# Extract "foo" and "baz" arguments from the input into
# FOO and BAZ shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "PACKAGE_FILE=\(.package_file) SOURCE_DIR=\(.source_dir)"')"

# Placeholder for whatever data-fetching logic your script implements
if [ ! -e $PACKAGE_FILE ]; then
    mkdir -p $(dirname $PACKAGE_FILE)
    # Generate empty file if there is no lambda package. Terraform will create a proper package later on.
    touch $PACKAGE_FILE
fi
# check lambda package and detect any code changes in 'src' directory
SHA256=$(find $PACKAGE_FILE $SOURCE_DIR -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{ print $1 }')

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg sha256 "$SHA256" '{"sha256":$sha256}'
