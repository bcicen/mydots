#!/bin/bash

gshow() {
  local full
  local showfmt='%C(auto)%H [%C(cyan)%G?%C(auto)] %n%an <%ae> %n%ad %C(black)%C(bold)| %cr%C(auto) %n%n %B'
  local opts=(--color=always)

  [[ $1 == "-f" ]] && { full=1; shift; } || opts+=("-q")

  git show ${opts[@]} --format="${showfmt}" $@

  [[ -z "$full" ]] && git diff --color=always --stat "$@^!"
}

[[ $# -lt 1 ]] && {
  echo "no commit provided"
  exit 1
}

gshow $@
