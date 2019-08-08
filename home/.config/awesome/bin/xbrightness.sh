#!/bin/bash

[[ $# -ne 1 ]] && {
  echo 'usage: xbrightness <float>'
  exit 0
}

target=$1

xrandr --listactivemonitors | awk '{print $4}' | while read x; do
  [[ -z "$x" ]] && continue
  xrandr --output $x --brightness $target
done
