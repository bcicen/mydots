#!/bin/bash

[[ $# != 2 ]] && {
  echo "usage: $0 {lip,wip,dns} <interface>"
  exit 1
}

case $1 in
  lip) ip a show dev $2 | grep inet | awk '{print $2}' | cut -f1 -d\/ ;;
  wip) curl -s --connect-timeout 3 icanhazip.com ;;
  dns) grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ' ;;
esac
