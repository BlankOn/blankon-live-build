#!/bin/bash

QUEUE="QUEUE.txt"

while true; do
  cat $QUEUE
  LEN=$(cat $QUEUE | wc -l)
  if [ "$LEN" -lt "1" ];then
    # Queue is empty. Let's wait for a sec.
    sleep 1
    continue
  fi

  # Split it by space. We're expecting repo URL, branch name and commit hash.
  JOB=($(head -n 1 $QUEUE))
  echo "Processing ${JOB[0]} ${JOB[1]} ${JOB[2]}..."
  ./build.sh ${JOB[0]} ${JOB[1]} ${JOB[2]}
  echo "Done."

  # Remove the job from queue 
  tail -n +2 $QUEUE > $QUEUE

done
