#homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

source "$HOME/.bash_colors"
source "$HOME/.fzf.bash"
source /usr/share/git/completion/git-prompt.sh

export GOPATH=~/go
export VISUAL=vim
export PYTHONSTARTUP=~/.pythonrc
export PYTHONPATH=~/.mypy/
export AMQP_URL=amqp://127.0.0.1:5672
export DOCKER_HOST=tcp://127.0.0.1:4243
PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin:$HOME/go/bin:$HOME/.pub-cache/bin

# history
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups
bind "set completion-ignore-case on"

# prompt
export PS1_CONCAT=0
_clrline=$(clr_magenta '─')
function _clrbrkt() { echo "$(clr_magenta '[')$@$(clr_magenta ']')"; }
function ps1t() {
  let PS1_CONCAT++
  if (($PS1_CONCAT % 2)); then
    PS1='$(clr_magenta ┌─=)$(_clrbrkt $(clr_white \t))${_clrline}$(_clrbrkt $(clr_white \u@\h))${_clrline}$(_clrbrkt \W)$(clr_green $(__git_ps1 "${_clrline}$(_clrbrkt $(clr_green %s))"))'
    PS1+='\n\[$FG_MAGENTA\]└[\[$CLR_RST\] '
  else
    PS1=' \[$FG_MAGENTA\][\[$CLR_RST\]'
    PS1+='\[$FG_WHITE\]\t\[$CLR_RST\]'
    PS1+='\[$FG_MAGENTA\]]\[$CLR_RST\]'
    PS1+='\[$FG_MAGENTA\]─\[$CLR_RST\]'
    PS1+=' \[$FG_MAGENTA\][\[$CLR_RST\]'
    PS1+='\[$FG_WHITE\]\W\[$CLR_RST\]'
    PS1+='\[$FG_MAGENTA\]]\[$CLR_RST\]'
    PS1+='\[$FG_MAGENTA\]─[\[$CLR_RST\] '
  fi
}
ps1t

#aliases
alias ll='ls --color -ltrha'
alias ls='ls --color'
alias pps="ps -eLo user,pid,ppid,pcpu,psr,pmem,stat,start,etime,cmd"
alias i3l='i3lock -c 000000'
alias hugoserv='hugo server -v --watch --buildDrafts'
alias xflux-est='killall xflux 2> /dev/null; xflux -l 40.712784 -g -74.005941'
alias xflux-sgn='killall xflux 2> /dev/null; xflux -l 40.712784 -g -74.005941'
alias get-scmver='python -c "from setuptools_scm import get_version; print(get_version())"'
alias pypi-publish='pandoc README.md -o README.rst && python2 setup.py sdist upload'
alias docker-cleanup='docker rm -vf $(docker ps -a --format "{{.ID}}" --filter "status=exited")'
alias stripws="sed -i.bak 's/[[:blank:]]*$//'"
alias pbcopy='xsel --clipboard --input'

#vim aliases
alias flog="vim ${HOME}/work/notes/$(date +%m-%d-%Y).log"
alias tlog="vim ${HOME}/work/notes/$(date +%Y-%m).log"
alias wlog="vim ${HOME}/work/notes/worklog.md"
alias vundle_install="vim +PluginInstall +qall"
function vimp() { /usr/bin/vim -p $@; }
function vimdir() { /usr/bin/vim -p $(find $@ -type f ! -ipath "*.git/*"); }

#functions
function ctof() { echo "scale=1; ($1*9) / 5 + 32" | bc; }
function ftoc() { echo "scale=1; ($1 - 32) / 1.8" | bc; }
function dusort() { du -hs $@/* | sort -h; }
function grepnotes() { find $HOME/work/notes/ -type f -iname "*log" -exec grep -Hi "$@" {} \; ; }
function litebrite() { echo $1 > /sys/class/backlight/intel_backlight/brightness; }

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
  git commit --date="$(TZ=:UTC date --rfc-2822)" -a -m "$commit_msg"

  prompt=$(clr_green "push?(y/N)")
  read -n1 -p "$prompt" do_push
  [ "$do_push" == "y" ] && {
    echo
    git push
  }
}

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

function servethis() {
  echo "starting container..."
  cid=$(docker run -d \
             -p 80 \
             -v ~/.resources/nginx.conf:/etc/nginx/nginx.conf \
             -v "${PWD}":/srv/www \
             vektorlab/nginx:latest)
  hostport=$(docker port $cid | cut -f2 -d\>)
  echo "nginx listening on $hostport"
  google-chrome-stable $hostport
}

function rgrep() {
  if [ $# -eq 2 ]; then
    rgx=$1
    shift
    find . -type f -iname "*.${rgx}" -exec grep -Hi "$@" {} \;
  else
    find . -type f -exec grep -Hi "$@" {} \;
  fi
}

function tsdocker() {
  case "$1" in
    set)
      [ -z "$oldps1" ] || export PS1=$oldps1
      export oldps1=$PS1
      if [ -z "$2" ];then
        unset DOCKER_HOST
      else
        export DOCKER_HOST="tcp://$2:4243"
        export PS1="${PS1:0:-3}(docker-$2)${oldps1:(-2)}"
      fi
      ;;
    "")
      echo "usage: tsdocker <hostname> docker command to run"
      echo "OR tsdocker set <hostname>"
      ;;
    *)
      h="$1"
      shift
      docker -H "tcp://$h:4243" $@
      ;;
  esac
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
  fi
}

#autocomplete
complete -W "$(cat ~/.ssh/known_hosts | cut -f1 -d ':' | sed 's/\[//g;s/\]//g' | tr '\n' ' ')" ssh
complete -W "$(cat ~/.ssh/known_hosts | cut -f1 -d ':' | sed 's/\[//g;s/\]//g' | tr '\n' ' ')" scp

source ~/.bashrcx
source ~/.tptrc
