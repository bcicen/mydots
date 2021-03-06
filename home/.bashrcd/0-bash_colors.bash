#!/bin/bash

CLR_RST=$(tput sgr0)

FG_BLACK=$(tput setaf 0)
FG_RED=$(tput setaf 1)
FG_GREEN=$(tput setaf 2)
FG_BROWN=$(tput setaf 3)
FG_BLUE=$(tput setaf 4)
FG_MAGENTA=$(tput setaf 5)
FG_CYAN=$(tput setaf 6)
FG_WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_BLUE=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_CYAN=$(tput setab 3)
BG_RED=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_BROWN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

_clr() {
  local clr=$1; shift
  echo "${!clr}$@${CLR_RST}"
}

_clr-table-256() {
  for i in {1..256}; do
    echo -n "$(_clr256 $i $(printf "%03d " $i)) "
  done
}

_clr256() {
  local code=$1; shift
  echo -ne "\033[38;5;${code}m$@\033[0m";
}

_clrRGB() {
  local r=${1:?} g=${2:?} b=${3:?}; shift 3
  echo -ne "$(_rgb $r $g $b)$@${CLR_RST}"
}

_clrHex() {
  local h=$1; shift
  _clrRGB $(_hex2rgb $h) $@
}

_hex2rgb() {
  local h=${1,,} # lower
  h=${h#\#} # strip leading '#'

  local r=${h:0:2} g=${h:2:2} b=${h:4:2}
  echo "$((16#$r)) $((16#$g)) $((16#$b))"
}

_rgb2hex() { printf '%x' $1 $2 $3; }

_rgb() { echo -en "\033[38;2;${1};${2};${3}m"; }

clr_black()        { _clr FG_BLACK $@; }
clr_red()          { _clr FG_RED $@; }
clr_green()        { _clr FG_GREEN $@; }
clr_brown()        { _clr FG_BROWN $@; }
clr_blue()         { _clr FG_BLUE $@; }
clr_magenta()      { _clr FG_MAGENTA $@; }
clr_cyan()         { _clr FG_CYAN $@; }
clr_white()        { _clr FG_WHITE $@; }

clr_blackb()       { _clr BG_BLACK $@; }
clr_redb()         { _clr BG_RED $@; }
clr_greenb()       { _clr BG_GREEN $@; }
clr_brownb()       { _clr BG_BROWN $@; }
clr_blueb()        { _clr BG_BLUE $@; }
clr_magentab()     { _clr BG_MAGENTA $@; }
clr_cyanb()        { _clr BG_CYAN $@; }
clr_whiteb()       { _clr BG_WHITE $@; }

#clr_reset_underline { clr_escape "$1" $CLR_RESET_UNDERLINE; }
#clr_reset_reverse   { clr_escape "$1" $CLR_RESET_REVERSE;   }
#clr_default         { clr_escape "$1" $CLR_DEFAULT;         }
#clr_defaultb        { clr_escape "$1" $CLR_DEFAULTB;        }
#clr_bold            { clr_escape "$1" $CLR_BOLD;            }
#clr_bright          { clr_escape "$1" $CLR_BRIGHT;          }
#clr_underscore      { clr_escape "$1" $CLR_UNDERSCORE;      }
#clr_reverse         { clr_escape "$1" $CLR_REVERSE;         }
