# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
for p in ${HOME}/.bashrcd/0-*; do source $p; done

[ -e "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
source /usr/share/git/completion/git-prompt.sh
source $HOME/.kubectl_completion

# internal helper fn
function _echoout() { echo "$(clr_cyan "stdout:") $@" > /dev/stdout; }
function _echoerr() { echo "$(clr_red "stderr:") $@" > /dev/stderr; }
# idempotent add path helper
function _pathadd() { [[ ! "$PATH" == *${1}* ]] && export PATH="$PATH:${1}"; }
# source-if-exists helper
function _source() { [[ -f "$1" ]] && . $1; }

export GOPATH=~/go
export VISUAL=vim
export PYTHONSTARTUP=~/.pythonrc
export PYTHONPATH=~/.mypy/
export AMQP_URL=amqp://127.0.0.1:5672
export KUBE_EDITOR=vim
export KUBECONFIG=~/.kube/config:~/.kube/kind-config-kind
export GPG_TTY=$(tty)

export NPM_PACKAGES="$HOME/.npm-packages"
_pathadd ${NPM_PACKAGES}/bin
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export MANPATH="$NPM_PACKAGES/share/man:$(manpath -q)"

# gcloud / Google Cloud SDK.
GCLOUDSDK_INSTALL_DIR="${HOME}/google-cloud-sdk"
_source ${GCLOUDSDK_INSTALL_DIR}/path.bash.inc
_source ${GCLOUDSDK_INSTALL_DIR}/completion.bash.inc

_pathadd ${HOME}/go/bin
_pathadd ${HOME}/.local/bin
_pathadd ${HOME}/.yarn/bin
_pathadd /usr/local/kubebuilder/bin
_pathadd /opt/bin

# history
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
# export histchars='@^#'

bind "set completion-ignore-case on"
#bind "set colored-stats on" # colorize complete options by filetype
#bind "set show-all-if-unmodified on" # complete show all opts on ambiguous

# prompt
export PS1_CONCAT=0
PS1_COLOR=$(_rgb 194 255 249)
function __ps1clr1 { _clrRGB 194 255 249 $@; }
function __ps1clr2 { _clrRGB 020 130 110 $@; }
function __ps1clr3 { _clrRGB 000 240 120 $@; }
function _clrbrkt() { echo " $@ $(__ps1clr1 '›')"; }

function ps1t() {
  let PS1_CONCAT++
  if (($PS1_CONCAT % 2)); then
    PS1='›'
    PS1+='$(_clrbrkt \t)$(_clrbrkt $(__ps1clr2 \W))$(__git_ps1 " $(_clrbrkt $(__ps1clr3 %s))")'
    PS1+='$(kube_ps1)'
    PS1+='\n \[$PS1_COLOR\]❭\[$CLR_RST\] '
  else
    PS1='›'
    PS1+='$(_clrbrkt $(__ps1clr2 \W))$(__git_ps1 " $(_clrbrkt $(__ps1clr3 %s))") '
  fi
}
ps1t

#aliases
alias ll='ls --color -ltrha'
alias ls='ls --color'
alias pps="ps -eLo user,pid,ppid,pcpu,psr,pmem,stat,start,etime,cmd"
alias i3l='i3lock -c 1c1c1c'
alias hugoserv='hugo server -v --watch --buildDrafts'
alias docker-cleanup='docker rm -vf $(docker ps -a --format "{{.ID}}" --filter "status=exited")'
alias stripws="sed -i.bak 's/[[:blank:]]*$//'"
alias pbcopy='xsel --clipboard --input'
alias drun='docker run --rm -ti'
dbuild() { docker build -t ${1-test} .; }

#vim aliases
alias flog="vim ${HOME}/work/notes/$(date +%m-%d-%Y).log"
alias vundle_install="vim +PluginInstall +qall"
function vimp() { /usr/bin/vim -p $@; }
function vimgo() { /usr/bin/vim -p $(find $@ -maxdepth 1 -iname "*.go" ! -iname "*_test.go"); }
function rgvim() { vim -p $(rgrep $@ | cut -f1 -d\: | uniq); }
function vimdir() {
  files=$(find ${@:-.} -type f ! -path "*.git/*")
  fileno=$(wc -w <<< $files)
  [[ $fileno -ge 12 ]] && {
    (__confirm "open $fileno files?") || return
  }
  vim -p $files
}

pylint-import() { pylint --disable=all -e W0411,W0611 $@; }

# functions
function ctof() { echo "scale=1; ($1*9) / 5 + 32" | bc; }
function ftoc() { echo "scale=1; ($1 - 32) / 1.8" | bc; }
function dusort() { path=$@; du -hs ${path:=.}/* | sort -h; }
function grepnotes() { find $HOME/work/notes/ -maxdepth 2 -type f -exec grep -Hi "$@" {} \; ; }
function litebrite() { echo $1 > /sys/class/backlight/intel_backlight/brightness; }
function isum() { local s=($@); tr ' ' '+' <<<${s[@]} | bc; }

function ragel2png() {
  [[ -z "$1" ]] && { _echoerr "usage: ragel2png <path> [<module name>]"; return; }
  local t="$(mktemp -u).dot" out=${1//rl/png} fn="main"
  [[ -z "$2" ]] || fn=$2
  ragel -Vp -M $fn $1 -o $t && dot $t -Tpng -o $out && _echoout "wrote $out"
}

function monbrite() {
  [[ $# -eq 0 ]] && {
    sudo ddccontrol -r 0x10 dev:/dev/i2c-13 | tail -n +25
    return
  }
  sudo ddccontrol -r 0x10 -w $1 dev:/dev/i2c-13 | tail -n +25
}

function hex2rgb() {
  input=${1#\#} # strip leading #, if any
  r=${input:0:2} g=${input:2:2} b=${input:4:2}
  echo "$((16#$r)) $((16#$g)) $((16#$b))"
}

function rgb2hex() { printf '%x' $1 $2 $3; }

function __is_int() { [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1; }
function __is_float() { [[ "$1" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] && return 0 || return 1; }

function gh-gosearch() {
  q=$@
  xdg-open "https://github.com/search?l=go&q=${q// /+}&type=Repositories&utf8=✓" 1> /dev/null
}

function pypi-publish() {
  pandoc README.md -o README.rst && \
  python setup.py sdist && \
  python setup.py bdist_wheel --universal && \
  twine upload dist/*
}

# open working repo ci jobs in browser
function glab-ci() {
  local group=$(dirname $(git remote get-url origin) | cut -f2 -d\:)
  local rname=$(basename $(git remote get-url origin) | sed 's/\.git//g')
  firefox "https://gitlab.com/${group}/${rname}/-/jobs"
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

# return url for remote origin
function _parse_repourl() {
  url=$(git remote get-url origin)
  url=${url##git@}
  url=${url##http://}
  url=${url##https://}
  url=${url%%.git}
  echo ${url//:/\/}
}

function _parse_reponame() { python -c 'import sys; print(sys.argv[1].split("/")[-1].replace(".git",""))' $@; }

function gdiff() { git diff --color $@ | diff-so-fancy; }
function groot() { cd $(git rev-parse --show-toplevel); }
function gstashi() { git stash push -- $@; }
function gbranch() {
  local opts
  [[ -z "$1" ]] && { echo "no branch provided"; return; }

  (__gbranches | grep -q -x $1) || {
    (__confirm "create new branch?") || return
    opts+="-b"
  }

  git checkout $opts $1;
}

gclean() {
  #local n=$(__guntracked | wc -l)
  #(__confirm "remove $n files?") || return
  basename $(pwd)
  tree --fromfile <(__guntracked) | grep -v '/dev/fd'
  (__confirm "clean all?") || return
  git clean -dxf
}

__guntracked() {
  local IFS=$(echo -en "\n\b")
  for i in $(git clean -ndxf | sed 's/Would\ remove\ //g'); do
    find "$i" -type f
    #find "$i" -type f | sort | tee >(cat 1>&2)
  done
}

#function __gbranches() { git branch -a --no-color | sed 's/\*//g;s/\ //g'; }

#complete -W "$(__gbranches)" gbranch

function gcommit() {
  commit_msg=$@
  git status -s

  [ ${#commit_msg} -lt 1 ] && {
    prompt=$(clr_green "commit msg> ")
    read -p "$prompt" commit_msg
  }
  [ ${#commit_msg} -lt 1 ] && { echo "no commit message provided"; return; }

  __gcommit "$commit_msg"
}

function gcommiti() {
  local commit_msg
  files=$@
  git diff --stat $files

  prompt=$(clr_green "commit msg> ")
  read -p "$prompt" commit_msg
  [ ${#commit_msg} -lt 1 ] && { echo "no commit message provided"; return; }

  __gcommit "$commit_msg" $files
}

function __gcommit() {
  msg=$1; shift
  files=$@

  ts="$(TZ=:UTC date --rfc-2822)"
  export GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts"
  if [[ -z "$files" ]]; then
    git commit -S -a -m "$msg"
  else
    git commit -S -m "$msg" $files
  fi
  unset GIT_COMMITTER_DATE GIT_AUTHOR_DATE

  (__confirm "push?") || return
  git push
}

function __confirm() {
  local x
  prompt=$(clr_green "$@(y/N)")
  read -n1 -p "$prompt" x; echo
  [ "$x" == "y" ] && return 0
  return 1
}

function rgrep() {
  local opts args

  for a in $@; do
    case $a in
      -*) opts+=($a) ;;
      *) args+=($a) ;;
    esac
  done

  opts="${opts[@]}" args="${args[@]}"
  _echoerr "opts: $opts"
  _echoerr "args: $args"

  rg ${opts} --no-ignore-vcs -g '!vendor/*' -g '!.git/*' "${args}"
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
  local args mon
  if (pgrep -x polybar); then
    killall polybar
  else
    args="-q"
    [[ "$1" == "debug" ]] && args="-r -l info"
    (xrandr | grep -q '^DP-3 connected') && mon="DP-3"
    MONITOR=$mon polybar $args main &
    MONITOR=$mon nohup polybar $args -c ~/.config/polybar/net net &
    MONITOR=$mon nohup polybar $args -c ~/.config/polybar/aux aux &
    MONITOR=$mon nohup polybar $args -c ~/.config/polybar/world_clock worldclock &
  fi
}

function stash() {
  local sroot=~/.stash ts=$(date +%Y.%M.%d-%H.%m.%S)
  local sfile spath abspath
  mkdir -p $sroot

  [[ "$1" == "ls" ]] && { ls -ltrha ${sroot}; return; }

  for path in $@; do
    abspath=$(readlink -f $path)
    spath=$(dirname $abspath)
    spath="${sroot}/${spath#/}"
    sfile=$(basename $abspath)

    mkdir -p $spath
    echo "cp -Rvi $path ${spath}/${sfile}-${ts}"
    cp -Rvi $path ${spath}/${sfile}-${ts}
  done
}

function tgz() {
  [[ $# -le 1 ]] && {
    echo "usage: tgz <archive.tgz> [<path>...]"
    return
  }
  local target=$1
  local -i total
  shift
  echo "calculating..."
  for path in $@; do
    total+=$(du -sb $path | awk '{print $1}')
  done
  tar cf - $@ -P | pv -s $total | gzip > $target
}

function kill-tabs() {
  kill -9 $(cpids $(pgrep firefox))
  /bin/kill-tabs
}

function cpids() {
  local -A cids

  while read pid ppid;do
    cids[$ppid]+=" $pid"
  done < <(ps -e -o pid= -o ppid=)

  walk() {
    for i in ${cids[$1]};do
      echo $i; walk $i
    done
  }

  for i in "$@";do
    walk $i
  done
}

# exif aliases
alias exift-erase="exiftool -all= -comment='0'"
alias exift-json="exiftool -struct -j"
alias exift-copyright="exiftool -CopyrightOwnerName='Bradley Cicenas <bradley@vektor.nyc>' -CopyrightOwnerID='bradley@vektor.nyc'"

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

__ssh_hosts() {
  local hosts
  hosts=$(awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' | cut -f1 -d\: | sed 's/\[//g;s/\]//g' | tr '\n' ' ')
  hosts+=" $(grep ^Host ~/.ssh/config | awk '{print $2}' | grep -v '*')"
  echo $hosts
}

# completion

__copy_complete() {
  local cmd=$(complete -p $1 | sed -E "s/(.*)$1/\1$2/") || return 1 && $cmd
}

complete -W "$(__ssh_hosts)" ssh
complete -W "$(__ssh_hosts)" scp
(command -v vault &> /dev/null) && complete -C $(command -v vault) vault
complete -F _complete_alias drun

source ~/.bashrcx
source ~/.tptrc
source ~/.gcloudrc

export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export GTK_IM_MODULE=ibus
