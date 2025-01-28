#1/bin/bash
echo "Collecting $1 RPMs"
reposync --download-metadata \
  --repo=$1 \
  -p /mnt/$1 > $1.log &
  pid=$!
echo "Process $pid is running"
while kill -0 $pid 2>/dev/null; do
  free -h
  df -h
  tail -n 1 $1.log
  echo
  sleep 15
done
echo "Process $pid is Complete"
ls -l /mnt/$1
du -sh /mnt/$1