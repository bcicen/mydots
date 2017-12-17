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
