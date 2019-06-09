# Setup fzf
# ---------
if [[ ! "$PATH" == */home/bradley/.fzf/bin* ]]; then
  export PATH="$PATH:/home/bradley/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/bradley/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/bradley/.fzf/shell/key-bindings.bash"

# Custom functions
# ------------

# git commit browser
glog() {
  local out sha q
  while out=$(
    git log --graph --color=always \
      --date="format:%b %e %H:%M:%S" \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cd (%cr)" "$@" |
    fzf --ansi --multi --no-sort --reverse --query="$q" --print-query -e); do
    q=$(head -1 <<< "$out")
    while read sha; do
      git show --color=always $sha | less -R
    done < <(sed '1d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
  done
}

__reldate() {
  local -i diff years=0 days=0 hours=0 minutes=0 seconds=0
  diff=$(echo "$(date +%s) - $1" | bc)

  while [[ $diff -ge 31536000 ]]; do
    diff=$((diff - 31536000))
    years+=1
  done

  while [[ $diff -ge 86400 ]]; do
    diff=$((diff - 86400))
    days+=1
  done

  while [[ $diff -ge 3600 ]]; do
    diff=$((diff - 3600))
    hours+=1
  done

  while [[ $diff -ge 60 ]]; do
    diff=$((diff - 60))
    minutes+=1
  done

  s=""
  [[ $years -gt 0 ]] && s+="${years}y"
  [[ $days -gt 0 ]] && s+=" ${days}d"
  [[ $hours -gt 0 ]] && s+=" ${hours}h"
  [[ $minutes -gt 0 ]] && s+=" ${minutes}m"
  [[ $seconds -gt 0 ]] && s+=" ${seconds}s"

  echo $s
}

__gstash_list() {
  git stash list --format='%C(yellow)%gd %C(auto)[%ct] %gs' --color=always | while read line; do
    ts=$(echo "$line" | sed 's/.*\[\([^]]*\)\].*/\1/g')
    echo $line | sed "s/$ts/$(__reldate $ts)/"
  done
}

# git commit browser
gstash() {
  local out sha q
  while out=$(
    __gstash_list |
    fzf --ansi --multi --no-sort --reverse --query="$q" --print-query -e); do
    q=$(head -1 <<< "$out")
    while read sha; do
      git show --color=always $sha | less -R
    done < <(echo "$out" | awk '{print $1}')
  done
}


# jump to go src dir
function cdgo() {
  srcdir="${GOPATH}/src/"

  out=$(find $srcdir -maxdepth 3 -mindepth 3 -xtype d ! -path '*/.*' | sort | sed "s|${srcdir}||g" | while read line; do
    parts=($(echo $line | sed 's|/|\n|g'))
    echo -e "\033[32m${parts[0]}\033[0m ${parts[1]}/${parts[2]}"
  done |  fzf --header=${srcdir} --height ${FZF_TMUX_HEIGHT:-40%} --ansi --multi --reverse --no-sort -e)
  [[ ! -z "$out" ]] && {
    path="${srcdir}$(echo $out | sed 's| |/|g')"
    cd $path
  }
}

# browser for large json objects or arrays
function fzf-json() {
  path=$1
  [[ -z "${path}" ]] && echo "usage: fzf-json <path>" && return

  filter='to_entries| .[] | { (.key): .value }' # object filter (default)
  [[ $(jq -r type < $path) == "array" ]] && filter='.[]'

  while out=$(jq -Cc "$filter" $path | fzf --ansi --multi --no-sort --reverse -e --preview='jq -C . <<< {}' --preview-window right:45%:wrap); do
    jq -C . <<< "$out" | less -Rc
  done
}

BM_PATH="${HOME}/.bm"

# simple bookmarking
function __bm_add__() {
  (grep -q "^${PWD}$" $BM_PATH) || echo $PWD >> $BM_PATH
  echo "bookmark added"
}

function __bm_rm__() {
  out=$(__bm_search__)
  [[ ! -z "$out" ]] && {
    for path in $out; do
      sed -i "/^${path//\//\\/}$/d" $BM_PATH
      echo "bookmark removed: $path"
    done
  }
}

function __bm_search__() {
  cat $BM_PATH | fzf --ansi --multi --reverse -e
}

function __bm_short_path() { echo ${@//$HOME/\~} ; }

function bm() {
  [[ ! -f ${BM_PATH} ]] && {
    echo "initializing bookmark file at $BM_PATH"
    touch $BM_PATH
  }

  [[ ! -z "$1" ]] && {
    case $1 in
      add) __bm_add__; return ;;
      rm) __bm_rm__; return ;;
      *) echo "unknown command"; return 1 ;;
    esac
  }

  out=$(__bm_search__)
  [[ ! -z "$out" ]] && cd $out
}

bind '"\C-b": " `__bm_search__`\e\C-e\e^\er"'

function __inline_help() {
  local cmd pos=0
  echo ${#READLINE_LINE} >> /tmp/envt
  echo ${READLINE_POINT} >> /tmp/envt
  while [[ $pos -lt $READLINE_POINT ]]; do
    ch=${READLINE_LINE:$pos:$((pos+1))}
    echo "ch[$pos:$((pos+1))]: $ch" >> /tmp/envt
    let pos++
  done
  echo $cmd >> /tmp/envt
}

bind -x '"\C-n": __inline_help'

TM_PATH="${HOME}/.tmux-sessions"

function __tm_list_sessions() {
  # output dead sessions
  comm -13 <(__tm_session_names) <(ls --color=never $TM_PATH | sort) | while read name; do
    echo "${name},(dead)"
  done

  # output live sessions
  fmt='#{session_name}|#{session_group}|#{session_id}|#{session_windows}|#{session_created}'
  tmux list-sessions -F $fmt 2> /dev/null | while read line; do
    IFS='|' read name group id winno created <<< $line
    echo "$name,($winno windows),(created $(date --date=@${created}))"
  done | sort
}

function __tm_session_names() { tmux list-sessions -F '#{session_name}' 2> /dev/null | sort ; }

function __tm_search__() {
  __tm_list_sessions | column -t -s ',' | fzf --ansi --multi --reverse -e
}

function tm() {
  out=$(__tm_search__)
  [[ -z "$out" ]] && return
  id=$(echo $out | awk '{print $1}')
  [[ "$(echo $out | awk '{print $2}')" == "(dead)" ]] && ${TM_PATH}/${id}
  tmux attach -t $id
}
