#!/bin/bash

MAX=80

[[ $# != 2 ]] && {
  echo "usage: $0 {text,bar} <zone>"
  exit 1
}

t=$(($(</sys/class/thermal/thermal_zone${2}/temp) / 1000))

case $1 in
  text) echo "${t}°C" ;;
  bar) ~/.config/polybar/bin/pbar $t ;;
esac
