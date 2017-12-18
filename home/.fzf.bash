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
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --multi --no-sort --reverse --query="$q" --print-query); do
    q=$(head -1 <<< "$out")
    while read sha; do
      git show --color=always $sha | less -R
    done < <(sed '1d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
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

  while out=$(jq -Cc "$filter" $path | fzf --ansi --multi --no-sort --reverse -e); do
    jq -C . <<< "$out" | less -Rc
  done
}
