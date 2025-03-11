#!/bin/bash

# Set the size limit in GB
LIMIT_GB=98
LIMIT_BYTES=$((LIMIT_GB * 1024 * 1024 * 1024))

# Initialize variables
current_size=0
group_number=1

# Create a directory to store the groups
mkdir -p grouped_files

# Function to add files to the current group
add_to_group() {
    local file=$1
    local size=$2

    if (( current_size + size > LIMIT_BYTES )); then
        group_number=$((group_number + 1))
        current_size=0
    fi

    echo "$file" >> grouped_files/group_$group_number.txt
    current_size=$((current_size + size))
}

# Iterate over the files in the directory
for file in /path/to/files/*; do
    if [[ -f $file ]]; then
        file_size=$(stat -c%s "$file")
        add_to_group "$file" "$file_size"
    fi
done

echo "Files have been grouped into grouped_files directory."