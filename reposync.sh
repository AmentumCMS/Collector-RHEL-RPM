#1/bin/bash
echo "Collecting $1 RPMs"
reposync --download-metadata \
  --repo=$1 \
  -p /mnt/$1 > $1.log &
  pid=$!
echo "Process $pid is running"
while kill -0 $pid 2>/dev/null; do
  echo -e "Free Mem:\t$(free -h | awk 'NR==2 {print $4}')" \
    "\t\tDisk Space:\t$(df -h /mnt | awk 'NR==2 {print $4}')" \
    "\n$(tail -n 1 $1.log)"
  # df -h /mnt | awk 'NR==2 {print $4}'
  # tail -n 1 $1.log
  sleep 15
done
echo "Process $pid is Complete"
echo -e "\nListing:\n$(ls -l /mnt/$1)\n"
echo -e "\nConsumption:\n$(du -sh /mnt/$1)\n"