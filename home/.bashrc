#homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

source "$HOME/.bash_colors"
[ -e "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
source /usr/share/git/completion/git-prompt.sh

export GOPATH=~/go
export VISUAL=vim
export PYTHONSTARTUP=~/.pythonrc
export PYTHONPATH=~/.mypy/
export AMQP_URL=amqp://127.0.0.1:5672
export DOCKER_HOST=tcp://127.0.0.1:2375
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
alias docker-cleanup='docker rm -vf $(docker ps -a --format "{{.ID}}" --filter "status=exited")'
alias stripws="sed -i.bak 's/[[:blank:]]*$//'"
alias pbcopy='xsel --clipboard --input'
alias drun='docker run --rm -ti'

#vim aliases
alias flog="vim ${HOME}/work/notes/$(date +%m-%d-%Y).log"
alias vundle_install="vim +PluginInstall +qall"
function vimp() { /usr/bin/vim -p $@; }
function vimdir() { /usr/bin/vim -p $(find $@ -type f ! -ipath "*.git/*"); }

#functions
function ctof() { echo "scale=1; ($1*9) / 5 + 32" | bc; }
function ftoc() { echo "scale=1; ($1 - 32) / 1.8" | bc; }
function dusort() { du -hs $@/* | sort -h; }
function grepnotes() { find $HOME/work/notes/ -type f -iname "*log" -exec grep -Hi "$@" {} \; ; }
function litebrite() { echo $1 > /sys/class/backlight/intel_backlight/brightness; }
function _echoerr() { echo "$(clr_red "stderr: ") $@"; }

function pypi-publish() {
  pandoc README.md -o README.rst && \
  python setup.py sdist && \
  python setup.py bdist_wheel --universal && \
  twine upload dist/*
}

# add new remote for forked gh repo
function ghfork() {
  #local branch=$(git rev-parse --abbrev-ref HEAD)
  local reponame=$(git remote -v | grep fetch  | awk '{print $2}' | cut -f5 -d\/)
  git remote add bcicen git@github.com:bcicen/$reponame
  git remote -v
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

function _rclone_parse() {
  url=$1
  case $url in
    https://github.com*)
      echo $url | cut -f4-5 -d\/ | _rclone_strip
      return
      ;;
    git@github.com*)
      echo $url | cut -f2 -d\: | _rclone_strip
      return
      ;;
    *)
      _echoerr "failed to parse repo url: $url"
      ;;
  esac
}

function _rclone_strip() { read x; echo $x | sed 's/.git//g;s/\//\ /g'; }

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

function rgrep() {
  local opts args

  for a in $@; do
  case $a in
    -*) opts+=($a) ;;
    *) args+=($a) ;;
  esac
  done

  if [ ${#args[@]} -eq 2 ]; then
    ftype=${args[0]}
    opts+=("-t${ftype}")
    args=(${args[1]})
  fi

  #echo "opts: ${opts[@]}"
  #echo "args: ${args[@]}"

  rg ${opts[@]} -g '!vendor/*' -g '!.git/*' ${args[@]}
}

function pyclean() {
  find . -type f -iname "*.pyc" -exec rm -vf {} \;
  find . -type d -name "__pycache__" -exec rmdir -v {} +;
}

function pyclean2() {
  pyclean
  rm -Rvf build/ dist/ *.egg-info
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

#autocomplete
known_hosts=$(awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' | cut -f1 -d\: | sed 's/\[//g;s/\]//g' | tr '\n' ' ')
complete -W "$known_hosts" ssh
complete -W "$known_hosts" scp

source ~/.bashrcx
source ~/.tptrc

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
