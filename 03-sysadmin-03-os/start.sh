#!/usr/bin/env bash

echo "Script ${0} running with PID: ${$}"
echo ${$}>pid.file

exec 10> random.log
while true
  do
    echo "${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}_${RANDOM}" >&10
  done
exec 10>&-
