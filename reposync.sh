#1/bin/bash
echo "Collecting $1 RPMs"
reposync --download-metadata \
  --repo=$1 \
  -p /mnt/$1 > $1.log &
  pid=$!
echo "Process $pid is running"
while kill -0 $pid 2>/dev/null; do
  free -h | awk 'NR==2 {print $4}'
  df -h /mnt | awk 'NR==2 {print $4}'
  tail -n 1 $1.log
  sleep 10
done
echo "Process $pid is Complete"