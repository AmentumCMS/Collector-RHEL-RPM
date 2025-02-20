#!/bin/bash

# Variables
CHUNK_SIZE=8000M  # DVD-DL size
ISO_SIZE=50000M   # BD-DL size
OUTPUT_DIR="/mnt/output"
ISO_DIR="$OUTPUT_DIR/iso_files"
REPO_NAME=$1

iso_count=1
current_iso_size=0
chunk_count=1
iso_file="$ISO_DIR/$REPO_NAME-$2-$iso_count.iso"

# Create necessary directories
mkdir -p "$ISO_DIR"
mkdir -p "$OUTPUT_DIR/$REPO_NAME"

# Compress the data into tar.gz chunks and create ISO files
cd "$OUTPUT_DIR/$REPO_NAME"
echo -e "\nCreating ISO file #$iso_file."
mkisofs -o "$iso_file" -J -R /dev/null  # Create an empty ISO to start with
find . -type f | split -b "$CHUNK_SIZE" -d -a 3 - "$REPO_NAME-" # Calculate chunks

echo -e "Chunks required: $(ls -1q $REPO_NAME-* | wc -l)\n$(ls -1 $REPO_NAME-*)\n$(ls -1q $REPO_NAME-*)"

# Create ISO files with the chunks
for chunk in $REPO_NAME-*; do
    echo -e "Creating chunk: $chunk"
    tar_chunk="$chunk.tar.gz"
    tar -czf "$tar_chunk" --remove-files "$chunk" \
      | tee $tar_chunk.txt
    tar_chunk_size=$(du -b "$tar_chunk" | cut -f1)
    echo -e "Chunk $tar_chunk is $tar_chunk_size bytes"
    
    if (( current_iso_size + tar_chunk_size > ISO_SIZE )); then
        echo "ISO file size limit reached ($current_iso_size). Closing ISO file."
        echo "Implanting MD5"
        implantisomd5 "$iso_file"
        echo "Calculating SHA256"
        sha256sum -b "$iso_file" | tee "$iso_file.sha"
        iso_count=$((iso_count++))
        current_iso_size=0
        chunk_count=1
        iso_file="$ISO_DIR/$REPO_NAME-$2-$iso_count.iso"
        echo -e "\nCreating next ISO file $iso_file."
        mkisofs -o "$iso_file" -J -R /dev/null  # Create a new empty ISO increment
    fi

    echo -e "Adding $tar_chunk to $iso_file"
    mkisofs -M "$iso_file" -o "$iso_file" -J -R "$tar_chunk"
    rm -fv "$tar_chunk"
    echo -e "Free Disk Space: $(df -h /mnt | awk 'NR==2 {print $4}')"
    current_iso_size=$((current_iso_size + tar_chunk_size))
    chunk_count=$((chunk_count++))
    echo -e "Current iso size $current_iso_size.  Next Chunk $chunk_count"
done

echo -e "Closing Final ISO"
implantisomd5 "$iso_file"
echo -e "Calculating SHA256"
sha256sum -b "$iso_file" | tee "$iso_file.sha"
gecho "Process completed. ISO files are located in $ISO_DIR"