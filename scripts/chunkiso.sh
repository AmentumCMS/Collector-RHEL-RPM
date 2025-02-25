#!/bin/bash
# Arguments
REPO_NAME=$1
DATE=$2

# Initialize variables
iso_count=1
chunk_count=1
current_iso_size=0

# Variables
ISO_FILE="$REPO_NAME-$DATE-$iso_count.iso"
chunks_per_iso=12
export chunkfiles="chunks"

# Create the batch list files
echo -e "Processing $REPO_NAME"
echo -e "Creating chunk lists."
chunklists.sh "$REPO_NAME"
# echo -e "\nChunks required: $(ls -1q $chunkfiles/$REPO_NAME-* | wc -l)\n$(ls -1 $chunkfiles/$REPO_NAME-*)\n$(ls -1q $chunkfiles/$REPO_NAME-*)"

# Create ISO files with the chunk file lists
echo -e "\nCreating blank ISO file $ISO_FILE."
mkisofs -o "$ISO_FILE" -J -R $chunkfiles/$REPO_NAME-*1* # Create an empty ISO to start with
echo

for chunk in $chunkfiles/$REPO_NAME-*; do
    echo "Adding chunk: $chunk"
    
    if (( chunk_count > chunks_per_iso )); then
        echo "ISO file size limit reached ($current_iso_size). Closing ISO file."
        # mkisofs -M "$ISO_FILE" -- outdev "$ISO_FILE" -commit
        echo "Implanting MD5"
        implantisomd5 "$ISO_FILE"
        echo "Calculating SHA256"
        sha256sum -b "$ISO_FILE" | tee "$ISO_FILE.sha"
        iso_count=$((iso_count + 1))
        current_iso_size=0
        chunk_count=1
        ISO_FILE="$REPO_NAME-$DATE-$iso_count.iso"
        echo -e "\nCreating next ISO file $ISO_FILE."
        mkisofs -o "$ISO_FILE" -J -R $chunk # Create a new empty ISO increment
    fi

    echo -e "Adding $chunk to $ISO_FILE"
    mkisofs -M $ISO_FILE -- outdev $ISO_FILE -add $(cat $chunk)
    echo -e "Deleting $chunk files"
    rm -f $(cat $chunk)
    echo -e "Free Disk Space: $(df -h . | awk 'NR==2 {print $4}')"
    current_iso_size=$((current_iso_size) + (stat -c%s "$ISO_FILE"))
    chunk_count=$((chunk_count + 1))
    echo -e "Current iso size $current_iso_size.  Next Chunk $chunk_count"
done

