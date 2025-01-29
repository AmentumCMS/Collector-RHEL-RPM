#1/bin/bash
echo "Collecting $1 RPMs"
reposync --download-metadata \
  --repo=$1 \
  -p /mnt/$1 > $1.log &
  pid=$!
echo "Process $pid is running"

while kill -0 $pid 2>/dev/null; do
  sleep 15
  echo -e "Free Mem: $(free -h | awk 'NR==2 {print $4}')" \
    "\tFree Space: $(df -h /mnt | awk 'NR==2 {print $4}')" \
    "\n$(tail -n 1 $1.log)"
done

echo "Process $pid is Complete"
echo -e "\nListing:\n$(ls -l /mnt/$1)"
echo -e "\nConsumption:\n$(du -sh /mnt/$1)"