#!/usr/bin/env bash

PID=$(cat pid.file)
echo "Stoping proccess with PID: ${PID}"
if kill -15 ${PID}
then
  echo "[OK] Proccess with PID ${PID} was successfully terminated!"
  rm -f pid.file
else
  echo "[ERROR]"
fi
