# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

for p in ${HOME}/.bashrcd/*; do source $p; done

# internal helper fn
_echoout() { echo "$(clr_cyan "stdout:") $@" > /dev/stdout; }
_echoerr() { echo "$(clr_red "stderr:") $@" > /dev/stderr; }
# idempotent add path helper
_pathadd() { [[ ! "$PATH" == *${1}* ]] && export PATH="$PATH:${1}"; }
# source-if-exists helper
_source() { [[ -f "$1" ]] && . $1; }

export GOPATH=~/go
export VISUAL=vim
export PYTHONSTARTUP=~/.pythonrc
export PYTHONPATH=~/.mypy/
export AMQP_URL=amqp://127.0.0.1:5672
export KUBE_EDITOR=vim
export KUBECONFIG=~/.kube/config:~/.kube/kind-config-kind
export GPG_TTY=$(tty)

# imibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export GTK_IM_MODULE=ibus

export NPM_PACKAGES="$HOME/.npm-packages"
_pathadd ${NPM_PACKAGES}/bin
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export MANPATH="$NPM_PACKAGES/share/man:$(manpath -q)"

_source ${HOME}/.kubectl_completion

# gcloud / Google Cloud SDK.
GCLOUDSDK_INSTALL_DIR="${HOME}/google-cloud-sdk"
_source ${GCLOUDSDK_INSTALL_DIR}/path.bash.inc
_source ${GCLOUDSDK_INSTALL_DIR}/completion.bash.inc

_pathadd ${HOME}/go/bin
_pathadd ${HOME}/.local/bin
_pathadd ${HOME}/.yarn/bin
_pathadd /usr/local/kubebuilder/bin
_pathadd /opt/bin
_pathadd ${HOME}/Android/Sdk/platform-tools

# history
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
# export histchars='@^#'

bind "set completion-ignore-case on"
#bind "set colored-stats on" # colorize complete options by filetype
#bind "set show-all-if-unmodified on" # complete show all opts on ambiguous

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
alias yaysss='yay -S --nodiffmenu --nocleanmenu --noeditmenu'
dbuild() { docker build -t ${1-test} .; }

#vim aliases
alias flog="vim ${HOME}/work/notes/$(date +%m-%d-%Y).log"
alias vundle_install="vim +PluginInstall +qall"
vimp() { /usr/bin/vim -p $@; }
vimu() { /usr/bin/vim -u NONE $@; }
vimgo() { /usr/bin/vim -p $(find $@ -maxdepth 1 -iname "*.go" ! -iname "*_test.go"); }
rgvim() { vim -p $(rgrep $@ | cut -f1 -d\: | uniq); }
vimdir() {
  local files=($(find -L ${@:-.} -type f ! -path "*.git/*"))
  [[ ${#files[@]} -ge 12 ]] && {
    (__confirm "open ${#files[@]} files?") || return
  }
  vim -p ${files[@]}
}

# clipboard aliases

alias cxget='xsel -bo'
alias cxput='xsel -bi'

cxedit () {
  local p=$(mktemp -u)
  [[ -z "$1" ]] || p=$(mktemp -u --suffix=".${1}")
  cxget > $p && vim $p
  cxput < $p && rm $p
}

alias vimclip='cxedit'

pylint-import() { pylint --disable=all -e W0411,W0611 $@; }

# functions
ctof() { echo "scale=1; ($1*9) / 5 + 32" | bc; }
ftoc() { echo "scale=1; ($1 - 32) / 1.8" | bc; }
dusort() { path=$@; du -hs ${path:=.}/* | sort -h; }
grepnotes() { find $HOME/work/notes/ -maxdepth 2 -type f -exec grep -Hi "$@" {} \; ; }
isum() { local s=($@); tr ' ' '+' <<<${s[@]} | bc; }

litebrite() {
  local -i n=$1 max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
  [[ -z "$n" ]] && return
  echo $((max*n/100)) > /sys/class/backlight/intel_backlight/brightness
}

ragel2png() {
  [[ -z "$1" ]] && { _echoerr "usage: ragel2png <path> [<module name>]"; return; }
  local t="$(mktemp -u).dot" out=${1//rl/png} fn="main"
  [[ -z "$2" ]] || fn=$2
  ragel -Vp -M $fn $1 -o $t && dot $t -Tpng -o $out && _echoout "wrote $out"
}

__monbrite_ids=""

_monbrite_probe() {
  [[ -z "$__monbrite_ids" ]] || return 0
  _echoerr "probing devices"
  local ids=$(sudo ddccontrol -p 2> /dev/null | grep -B2 'LG Standard' | grep Device | cut -f2- -d\: | tr '\n' ' ')
  local res=$?
  _echoerr "found ids: $ids"
  export __monbrite_ids="$ids"
  return $res
}

monbrite() {
  local opts=""
  [[ -z "$1" ]] || opts+="-w $1"

  _monbrite_probe || return

  for id in $__monbrite_ids; do
    echo -e "\n# $id"
    sudo ddccontrol -r 0x10 ${opts} ${id} | tail -n +25
  done
}

monoff() { sleep 1; xset dpms force off; }

__is_int() { [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1; }
__is_float() { [[ "$1" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] && return 0 || return 1; }

gh-gosearch() {
  q=$@
  xdg-open "https://github.com/search?l=go&q=${q// /+}&type=Repositories&utf8=✓" 1> /dev/null
}

pypi-publish() {
  pandoc README.md -o README.rst && \
  python setup.py sdist bdist_wheel && \
  twine upload dist/*
}

alias pyvenv='python -m venv'

# open working repo ci jobs in browser
glab-ci() {
  local group=$(dirname $(git remote get-url origin) | cut -f2 -d\:)
  local rname=$(basename $(git remote get-url origin) | sed 's/\.git//g')
  firefox "https://gitlab.com/${group}/${rname}/-/jobs"
}

# open working gh repo in browser
ghopen() {
  arg=$1
  remote=$(git remote get-url ${arg:=origin})
  [[ $? -eq 0 ]] && {
    url=$(echo $remote | sed 's/https:\/\///g;s/git@//g;s/:/\//g')
    xdg-open https://${url}
  }
}

# add new remote for forked gh repo
ghfork() {
  #local branch=$(git rev-parse --abbrev-ref HEAD)
  local reponame=$(git remote -v | grep fetch  | awk '{print $2}' | cut -f5 -d\/)
  git remote add bcicen git@github.com:bcicen/$reponame
  git remote -v
}

golnsrc() {
  url=$(git config --get remote.origin.url)
  path=$(echo $url | sed 's/\.git//;s/https:\/\///;s/:/\//g' | cut -f2 -d@)
  tgt=${GOPATH}/src/${path}
  [[ -d "$(dirname $tgt)" ]] || mkdir -pv "$(dirname $tgt)"
  [[ -e "${tgt}" ]] && { _echoerr "${tgt} exists"; return; }
  ln -sv $(git rev-parse --show-toplevel) ${tgt}
}

rclone() {
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
_parse_repourl() {
  url=$(git remote get-url origin)
  url=${url##git@}
  url=${url##http://}
  url=${url##https://}
  url=${url%%.git}
  echo ${url//:/\/}
}

_parse_reponame() { python -c 'import sys; print(sys.argv[1].split("/")[-1].replace(".git",""))' $@; }

gdifff() { git diff --color $@ | diff-so-fancy; }
gdiff() { git diff --color --numstat; git diff --color --numstat --cached; }
groot() { cd $(git rev-parse --show-toplevel); }
gstashi() { git stash push -- $@; }

gstat() {
  local opts="-C ${@:-.}"
  local add=$(_clrHex "#7FE9A2" " A")
  local del=$(_clrHex "#FE7FAC" " D")
  local mod=$(_clrHex "#75DEF1" " M")
  echo "branch $(git $opts branch --show-current)"
  git $opts status -s | sed "s/^A\ / ${add}/;s/^\ M/ ${mod}/;s/^\ D/ ${del}/"
}

gdirs-diff() {
  local -i n rn
  gdirs $@ | while read p; do
    [[ "$(gdiffs | wc -l)" -ne 0 ]] && {
      echo -e "\n### $(clr_green $p)"
      gdiffs; echo
      let rn++ n+=
    }
    cd - &> /dev/null
  done
}

__gdir-diff() {
  gdirs | while read p; do
    cd $p 
    [[ "$(gdiffs | wc -l)" -ne 0 ]] && {
      echo -e "### $(clr_green $p)\n"
      gdiffs; echo
    }
    cd - &> /dev/null
  done
}


gdirs() {
  for i in $(find ${@:-.} -type d -iname ".git");
    do echo ${i%%/.git};
  done
}

gtaga() {
  local tag=$1; shift
  git tag -a -m "$tag" $tag $@
}
gtagd() {
  local tag=$1; shift
  git tag -d $tag
  git push origin :refs/tags/${tag}
}
gbranch() {
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

gcommit() {
  commit_msg=$@
  git status -s

  [ ${#commit_msg} -lt 1 ] && {
    prompt=$(clr_green "commit msg> ")
    read -p "$prompt" commit_msg
  }
  [ ${#commit_msg} -lt 1 ] && { echo "no commit message provided"; return; }

  __gcommit "$commit_msg"
}

gcommiti() {
  local commit_msg
  files=$@
  git diff --stat $files

  prompt=$(clr_green "commit msg> ")
  read -p "$prompt" commit_msg
  [ ${#commit_msg} -lt 1 ] && { echo "no commit message provided"; return; }

  __gcommit "$commit_msg" $files
}

__gcommit() {
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

__confirm() {
  local x
  prompt=$(clr_green "$@(y/N)")
  read -n1 -p "$prompt" x; echo
  [ "$x" == "y" ] && return 0
  return 1
}

rgrep() {
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

  rg ${opts} --no-ignore-vcs -g '!vendor/*' -g '!.git/*' -g '!node_modules/*' "${args}"
}

pyclean() {
  count=$(wc -l <(find . -type f -iname "*.pyc" -exec rm -vf {} \;) | awk '{print $1}')
  let count+=$(wc -l <(find . -type d -name "__pycache__" -exec rmdir -v {} +;) | awk '{print $1}')
  _echoout "removed ${count} pycache files"
}

pyclean2() {
  sudo chown -Rcf ${USER}. .
  pyclean
  rm -Rf build/ dist/ *.egg-info
}

# clipboard functions/aliases
clip-parse-email() {
  clipit $(echo $@ | grep -o "[[:alnum:][:graph:]]*@[[:alnum:][:graph:]]*" | sed 's/mailto://g')
}

cbar() {
  if (pgrep -x conky); then
    killall conky
  else
    nohup conky -c ~/.conky/Wonky/Wonky &> /dev/null &
    sleep 1
    nohup conky -c ~/.conky/Wonky/WorldClock &> /dev/null &
  fi
}

pbar() {
  (pgrep -x polybar) && { killall polybar; return; }
  local args mon=$(xrandr | grep -e '^DP-1.* connected' | tail -1 | awk '{print $1}')
  [[ "$1" == "debug" ]] && args="-r -l info"
  MONITOR=$mon polybar $args main &
  MONITOR=$mon nohup polybar $args -c ~/.config/polybar/net net &
  MONITOR=$mon nohup polybar $args -c ~/.config/polybar/aux aux &
  MONITOR=$mon nohup polybar $args -c ~/.config/polybar/world_clock worldclock &
}

stash() {
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

tgz() {
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

kill-tabs() { kill -9 $(cpids $(pgrep firefox)); }

cpids() {
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

qr() {
  local f="$(mktemp -u).png"
  qrencode -s 25 -l H -o "$f" $@
  timeout 30s feh -g 800x800 --zoom fill $f
}

jless() { jq -C . < $1 | less -r; }

# exif aliases
alias exift-erase="exiftool -all= -comment='0'"
alias exift-json="exiftool -struct -j"
alias exift-copyright="exiftool -CopyrightOwnerName='Bradley Cicenas <bradley@vektor.nyc>' -CopyrightOwnerID='bradley@vektor.nyc'"

gorunloop() {
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

bashman() { man bash | less -p "^       $1 "; }

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
