#!/bin/sh
# wait-for-file.sh

FILES=$1
shift
CMD=$@

for FILE in $FILES; do
  while [ ! -f $FILE ]; do
    echo "Waiting for file $FILE to be created..."
    sleep 2
  done
done

exec $CMD

