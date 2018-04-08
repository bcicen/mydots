#!/bin/bash

[[ $# != 3 ]] && {
  echo "usage: $0 {rx,tx} <interface> <interval>"
  exit 1
}

iface=$2
interval=$3

rate=($(ifstat -j ${iface}| jq -r ".kernel.${iface} | map_values(tostring) | .rx_bytes + \" \" + .tx_bytes"))

rxfile="${TMP:-/tmp}/pbar-${iface}-rx"
txfile="${TMP:-/tmp}/pbar-${iface}-tx"

case $1 in
  rx)
    lastrx=$(cat $rxfile 2> /dev/null)
    change=$((${rate[0]} - ${lastrx:-0}))
    echo "$(($change / $interval))" | numfmt --to=iec --suffix=B/s
    echo ${rate[0]} > $rxfile
    ;;
  tx)
    lasttx=$(cat $txfile 2> /dev/null)
    change=$((${rate[1]} - ${lasttx:-0}))
    echo "$(($change / $interval))" | numfmt --to=iec --suffix=B/s
    echo ${rate[1]} > $txfile
    ;;
esac
