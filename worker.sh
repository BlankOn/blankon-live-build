#!/bin/bash

QUEUE="QUEUE.txt"


while true; do
  cat $QUEUE
  LEN=$(cat $QUEUE | wc -l)
  echo $LEN
  if [ "$LEN" -lt "1" ];then
    echo "Queue is empty."
    sleep 5
    continue
  fi
  JOB=($(head -n 1 $QUEUE))
  
  echo "Processing ${JOB[0]} ${JOB[1]} ${JOB[2]}..."
  ./build.sh ${JOB[0]} ${JOB[1]} ${JOB[2]}
  echo "Done."
  sleep 1
  tail -n +2 $QUEUE > $QUEUE
done
