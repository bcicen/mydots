#!/bin/bash

HI_COLOR="#c2fff9"

[[ $# != 2 ]] && {
  echo "usage: $0 <interface> <interval>"
  exit 1
}

iface=$1
interval=$2
last_bytes=(0 0)

_fmt() { echo "$@" | numfmt --to=iec --suffix=b/s --format='%03f'; }

_output() {
  rx=${1:-0} tx=${2:-0}
  echo -n "%{F${HI_COLOR}}⬃ %{F-} $(_fmt $rx)"
  echo " %{F${HI_COLOR}}⬀ %{F-} $(_fmt $tx)"
}

while :; do
  # defaults (rx,tx)
  rate=(0 0)
  cur_bytes=(0 0)

  grep -q up /sys/class/net/${iface}/operstate || {
    _output
   sleep $interval
   continue
  }

  cur_bytes=($(ifstat -j ${iface}| jq -r ".kernel.${iface} | map_values(tostring) | .rx_bytes + \" \" + .tx_bytes"))
  rx_rate=$(((${cur_bytes[0]} - ${last_bytes[0]}) / $interval))
  tx_rate=$(((${cur_bytes[1]} - ${last_bytes[1]}) / $interval))

  _output $rx_rate $tx_rate
  last_bytes=(${cur_bytes[@]})

  sleep $interval
done
