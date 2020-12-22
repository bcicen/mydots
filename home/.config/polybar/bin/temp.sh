#!/bin/bash

MAX=80

[[ $# != 2 ]] && {
  echo "usage: $0 {text,bar} <zone>"
  exit 1
}

t=$(($(</sys/class/hwmon/hwmon7/temp1_input) / 1000))
#t=$(sensors coretemp-isa-0000 -u | grep temp1_input | cut -f2 -d\: | cut -f1 -d\.)

case $1 in
  text) echo "${t}°C" ;;
  bar) ~/.config/polybar/bin/pbar $t ;;
esac
