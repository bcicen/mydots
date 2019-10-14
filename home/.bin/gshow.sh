#!/bin/bash

__gshow_header() {
  local showfmt='%C(auto)%H [%C(cyan)%G?%C(auto)] %n%an <%ae> %n%ad %C(black)%C(bold)| %cr%C(auto) %n%n %B'
  local opts=("--color=always" "-q")
  git show ${opts[@]} --format="${showfmt}" $1
}

gshow() {
  local opts=("--color=always" "--format=")

  [[ $1 == "-f" ]] && shift || opts+=("--stat")

  __gshow_header $@
  git show ${opts[@]} $@
}

[[ $# -lt 1 ]] && {
  echo "no commit provided"
  exit 1
}

gshow $@
