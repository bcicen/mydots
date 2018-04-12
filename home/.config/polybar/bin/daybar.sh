#!/bin/bash

WIDTH=24
DATE_TOGGLE=0

empty="○"
space="   "
#space=" "
half="◐"
fill="●"

toggle() { DATE_TOGGLE=$((($DATE_TOGGLE + 1) % 2)); }

function mkbar() {
  ((hour=10#$(date +%H)+1))
  [[ $((10#$(date +%M))) -gt 29 ]] && let hour++

  filln=$(($((WIDTH * hour)) / 24))

  i=0 bar=""
  while [[ $i -lt $filln ]]; do
    bar+="${fill}${space}"
    let i++
  done

  while [[ $i -lt $WIDTH ]]; do
    bar+="${empty}${space}"
    let i++
  done

  echo "$bar"
}

trap "toggle" USR1

while :; do
  if [[ $DATE_TOGGLE == 0 ]]; then
    mkbar
  else
    date "+%A, %B %d"
  fi
  sleep 5 &
  wait
done
