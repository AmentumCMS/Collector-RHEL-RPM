#!/bin/bash
set +e
REPO_NAME=$1

# Set the size limit in GB
LIMIT_GB=8
LIMIT_BYTES=$((LIMIT_GB * 1024 * 1024 * 1024))

# Initialize variables
current_size=0
group_number=1

if [[ -z $chunkfiles ]]; then
    export chunkfiles="group_files"
fi
echo "Using dir: $chunkfiles"

# Create a directory to store the groups
if [[ -d $chunkfiles ]]; then
    rm -rf $chunkfiles
fi
mkdir -p $chunkfiles

# Function to add files to the current group
add_to_group() {
    local file=$1
    local size=$2

    if (( current_size + size > LIMIT_BYTES )); then
        echo "Group list $REPO_NAME-$group_number.txt created"
        group_number=$((group_number + 1))
        current_size=0
    fi
    echo "$file" >> $chunkfiles/$REPO_NAME-$group_number.txt
    current_size=$((current_size + size))
}

echo -e "Creating chunk lists in $chunkfiles."

# Iterate over the files in the directory
while read -r file; do
    if [[ -f $file ]]; then
        file_size=$(stat -c%s "$file")
        add_to_group "$file" "$file_size"
    fi
done < <(find $REPO_NAME -type f)
echo "Group list $REPO_NAME-$group_number.txt created"

echo -e "\n$(ls -1 $chunkfiles|wc -l) group list files in $chunkfiles directory."