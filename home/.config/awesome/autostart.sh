#!/usr/bin/env bash
# ---
# NOTE: This script runs with every restart of AwesomeWM
# If you would like to run a command *once* on login,
# you can use ~/.xprofile

function run { (pgrep $1 > /dev/null) || $@& }

xrdb ~/.Xresources

if [ ! -e /tmp/mpv.fifo ]; then
    mkfifo /tmp/mpv.fifo
fi

run clipit
xflux-auto
