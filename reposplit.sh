#!/bin/bash

# Variables
CHUNK_SIZE=8500M  # DVD-DL size
ISO_SIZE=50000M   # BD-DL size
OUTPUT_DIR="/mnt/output"
ISO_DIR="$OUTPUT_DIR/iso_files"
REPO_NAME=$1

# Create necessary directories
mkdir -p "$ISO_DIR"
mkdir -p "$OUTPUT_DIR/$REPO_NAME"

# Step 1: Sync the repository using reposync
echo "Collecting $REPO_NAME RPMs"
reposync --download-metadata --downloadcomps \
  --repo=$REPO_NAME \
  -p $OUTPUT_DIR > $REPO_NAME.log &
  pid=$!
echo "Process $pid is running"

while kill -0 $pid 2>/dev/null; do
  sleep 15
  echo -e "Free Mem: $(free -h | awk 'NR==2 {print $4}')" \
    "\tFree Space: $(df -h /mnt | awk 'NR==2 {print $4}')" \
    "\n$(tail -n 1 $REPO_NAME.log)"
done

echo "Process $pid is Complete"
echo -e "\nConsumption:\n$(du -sh $OUTPUT_DIR/$1)\n"

# Step 2: Compress the data into tar.gz chunks and create ISO files
iso_count=0
current_iso_size=0
chunk_count=0
iso_file="$ISO_DIR/$REPO_NAME-$iso_count.iso"

cd "$OUTPUT_DIR/$REPO_NAME"
mkisofs -o "$iso_file" -J -R /dev/null  # Create an empty ISO to start with
find . -type f | split -b "$CHUNK_SIZE" -d -a 3 - "$REPO_NAME-"

echo -e "Chunks required: $(ls -1q $REPO_NAME-* | wc -l)\n$(ls -1 $REPO_NAME-*)\n$(ls -1q $REPO_NAME-*)"

for chunk in $REPO_NAME-*; do
    tar_chunk="$chunk.tar.gz"
    tar -czf "$tar_chunk" --remove-files "$chunk" \
      | tee $tar_chunk.txt
    mkisofs -o "$iso_file" "$tar_chunk"
    rm "$tar_chunk"
    chunk_count=$((chunk_count++))

    if (( current_iso_size + tar_chunk_size > ISO_SIZE )); then
        iso_count=$((iso_count++))
        current_iso_size=0
        iso_file="$ISO_DIR/$REPO_NAME-$iso_count.iso"
        mkisofs -o "$iso_file" -J -R /dev/null  # Create a new empty ISO increment
    fi

    mkisofs -M "$iso_file" -o "$iso_file" -J -R "$tar_chunk"
    rm "$tar_chunk"
    current_iso_size=$((current_iso_size + tar_chunk_size))
done

echo "Process completed. ISO files are located in $ISO_DIR"