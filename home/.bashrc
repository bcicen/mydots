# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

source "$HOME/.bash_colors"
[ -e "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
source /usr/share/git/completion/git-prompt.sh

# internal helper fn
function _echoout() { echo "$(clr_cyan "stdout:") $@" > /dev/stdout; }
function _echoerr() { echo "$(clr_red "stderr:") $@" > /dev/stderr; }
# idempotent add path helper
function _pathadd() { [[ ! "$PATH" == *${1}* ]] && export PATH="$PATH:${1}"; }

export GOPATH=~/go
export VISUAL=vim
export PYTHONSTARTUP=~/.pythonrc
export PYTHONPATH=~/.mypy/
export AMQP_URL=amqp://127.0.0.1:5672
_pathadd ${HOME}/go/bin
_pathadd ${HOME}/.local/bin
_pathadd ${HOME}/.yarn/bin

# history
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups
# export histchars='@^#'

bind "set completion-ignore-case on"

# prompt
export PS1_CONCAT=0
PS1_COLOR=$(_rgb 194 255 249)
function clr_ps1 { _clrRGB 194 255 249 $@; }
function _clrbrkt() { echo "$(clr_ps1 '[')$@$(clr_ps1 ']')"; }
_clrline=$(clr_ps1 '─')
function ps1t() {
  let PS1_CONCAT++
  if (($PS1_CONCAT % 2)); then
    PS1='$(clr_ps1 ┌─=)$(_clrbrkt $(clr_white \t))${_clrline}$(_clrbrkt $(clr_white \u@\h))${_clrline}$(_clrbrkt \W)$(clr_green $(__git_ps1 "${_clrline}$(_clrbrkt $(clr_green %s))"))'
    PS1+='\n\[$PS1_COLOR\]└[\[$CLR_RST\] '
  else
    PS1=' \[$PS1_COLOR\][\[$CLR_RST\]'
    PS1+='\[$FG_WHITE\]\t\[$CLR_RST\]'
    PS1+='\[$PS1_COLOR\]]\[$CLR_RST\]'
    PS1+='\[$PS1_COLOR\]─\[$CLR_RST\]'
    PS1+='\[$PS1_COLOR\][\[$CLR_RST\]'
    PS1+='\[$FG_WHITE\]\W\[$CLR_RST\]'
    PS1+='\[$PS1_COLOR\]]\[$CLR_RST\]'
    PS1+='\[$PS1_COLOR\]─[\[$CLR_RST\] '
  fi
}
ps1t

#aliases
alias ll='ls --color -ltrha'
alias ls='ls --color'
alias pps="ps -eLo user,pid,ppid,pcpu,psr,pmem,stat,start,etime,cmd"
alias i3l='i3lock -c 000000'
alias hugoserv='hugo server -v --watch --buildDrafts'
alias docker-cleanup='docker rm -vf $(docker ps -a --format "{{.ID}}" --filter "status=exited")'
alias stripws="sed -i.bak 's/[[:blank:]]*$//'"
alias pbcopy='xsel --clipboard --input'
alias drun='docker run --rm -ti'

#vim aliases
alias flog="vim ${HOME}/work/notes/$(date +%m-%d-%Y).log"
alias vundle_install="vim +PluginInstall +qall"
function vimp() { /usr/bin/vim -p $@; }
function vimgo() { /usr/bin/vim -p $(find $@ -maxdepth 1 -iname "*.go" ! -iname "*_test.go"); }

#functions
function ctof() { echo "scale=1; ($1*9) / 5 + 32" | bc; }
function ftoc() { echo "scale=1; ($1 - 32) / 1.8" | bc; }
function dusort() { path=$@; du -hs ${path:=.}/* | sort -h; }
function grepnotes() { find $HOME/work/notes/ -type f -exec grep -Hi "$@" {} \; ; }
function litebrite() { echo $1 > /sys/class/backlight/intel_backlight/brightness; }
function isum() { local s=($@); tr ' ' '+' <<<${s[@]} | bc; }

function gh-gosearch() {
  q=$@
  xdg-open "https://github.com/search?l=go&q=${q// /+}&type=Repositories&utf8=✓" 1> /dev/null
}

function pypi-publish() {
  #pandoc README.md -o README.rst && \
  python setup.py sdist && \
  python setup.py bdist_wheel --universal && \
  twine upload dist/*
}

# open working gh repo in browser
function ghopen() {
  arg=$1
  remote=$(git remote get-url ${arg:=origin})
  [[ $? -eq 0 ]] && {
    url=$(echo $remote | sed 's/https:\/\///g;s/git@//g;s/:/\//g')
    xdg-open https://${url}
  }
}

# add new remote for forked gh repo
function ghfork() {
  #local branch=$(git rev-parse --abbrev-ref HEAD)
  local reponame=$(git remote -v | grep fetch  | awk '{print $2}' | cut -f5 -d\/)
  git remote add bcicen git@github.com:bcicen/$reponame
  git remote -v
}

function golnsrc() {
  url=$(git config --get remote.origin.url)
  path=$(echo $url | sed 's/\.git//;s/https:\/\///;s/:/\//g' | cut -f2 -d@)
  tgt=${GOPATH}/src/${path}
  [[ -d "$(dirname $tgt)" ]] || mkdir -v "$(dirname $tgt)"
  [[ -e "${tgt}" ]] && { _echoerr "${tgt} exists"; return; }
  ln -sv $(git rev-parse --show-toplevel) ${tgt}
}

function rclone() {
  local base_dir=${HOME}/repos
  [ $# != 1 ] && {
    echo "usage: rclone <url>"
    return
  }

  # parse repo url
  url=$1
  repo_name=$(_parse_reponame $url)
  repo_dir=${base_dir}/${repo_name}
  [ -d $repo_dir ] && {
    _echoerr "$repo_dir exists"
    cd $repo_dir
    return
  }

  git clone $url $repo_dir && cd $repo_dir
}

function _parse_reponame() { python -c 'import sys; print(sys.argv[1].split("/")[-1].replace(".git",""))' $@; }

function gdiff() { git diff --color $@ | diff-so-fancy; }

function gcommit() {
  commit_msg=$@
  git status -s
  [ $(echo $commit_msg| wc -w) -lt 1 ] && {
    prompt=$(clr_green "commit msg> ")
    read -p "$prompt" commit_msg
  }
  [ $(echo $commit_msg| wc -w) -lt 1 ] && {
    echo "no commit message provided"
    return
  }
  ts="$(TZ=:UTC date --rfc-2822)"
  export GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts"
  git commit -a -m "$commit_msg"
  unset GIT_COMMITTER_DATE GIT_AUTHOR_DATE

  prompt=$(clr_green "push?(y/N)")
  read -n1 -p "$prompt" do_push
  [ "$do_push" == "y" ] && {
    echo
    git push
  }
}

function rgrep() {
  local opts args

  for a in $@; do
  case $a in
    -*) opts+=($a) ;;
    *) args+=($a) ;;
  esac
  done

  echo "opts: ${opts[@]}"
  echo "args: ${args[@]}"

  rg ${opts[@]} -g '!vendor/*' -g '!.git/*' "${args[@]}"
}

function pyclean() {
  count=$(wc -l <(find . -type f -iname "*.pyc" -exec rm -vf {} \;) | awk '{print $1}')
  let count+=$(wc -l <(find . -type d -name "__pycache__" -exec rmdir -v {} +;) | awk '{print $1}')
  _echoout "removed ${count} pycache files"
}

function pyclean2() {
  sudo chown -Rcf ${USER}. .
  pyclean
  rm -Rf build/ dist/ *.egg-info
}

# clipboard functions/aliases
function clip-parse-email() {
  clipit $(echo $@ | grep -o "[[:alnum:][:graph:]]*@[[:alnum:][:graph:]]*" | sed 's/mailto://g')
}

function cbar() {
  if (pgrep -x conky); then
    killall conky
  else
    nohup conky -c ~/.conky/Wonky/Wonky &> /dev/null &
    sleep 1
    nohup conky -c ~/.conky/Wonky/WorldClock &> /dev/null &
  fi
}

function pbar() {
  if (pgrep -x polybar); then
    killall polybar
  else
    args="-q"
    [[ "$1" == "debug" ]] && args="-r -l info"
    polybar $args main &
    nohup polybar $args -c ~/.config/polybar/net net &
    nohup polybar $args -c ~/.config/polybar/aux aux &
    nohup polybar $args -c ~/.config/polybar/world_clock worldclock &
  fi
}

function gorunloop() {
  target=$1
  while :; do
    go run $target &
    p=$!
    inotifywait -q -e modify $target
    _echoout "reload"
    kill $p $(pgrep -P $p)
    wait
  done
}

#autocomplete
known_hosts=$(awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' | cut -f1 -d\: | sed 's/\[//g;s/\]//g' | tr '\n' ' ')
complete -W "$known_hosts" ssh
complete -W "$known_hosts" scp

source ~/.bashrcx
source ~/.tptrc
source ~/.gcloudrc

export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export GTK_IM_MODULE=ibus
