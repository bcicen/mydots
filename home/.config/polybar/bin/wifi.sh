#!/bin/bash

[[ $# != 2 ]] && {
  echo "usage: $0 {text,bar} <interface>"
  exit 1
}

case $1 in
  text)
    essid=$(iwconfig $2 | grep ESSID | cut -f2 -d\:)
    essid=${essid//\"/}
    [[ ${#essid} -gt 14 ]] && essid="${essid:0:12}..."
    echo $essid
    ;;
  bar)
    level=$(awk 'NR==3 {print $3}' /proc/net/wireless)
    level=${level:-0}
    ~/.config/polybar/bin/pbar ${level%.}
    ;;
esac
