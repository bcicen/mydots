#homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"

source "$HOME/.bash_colors"

export GOPATH=~/go
export VISUAL=vim
export PYTHONSTARTUP=~/.pythonrc
export PYTHONPATH=~/.mypy/
export HISTFILESIZE=10000
PATH=$PATH:$HOME/.gem/ruby/2.2.0/bin:$HOME/go/bin:$HOME/.pub-cache/bin

#default to local docker over tcp
export DOCKER_HOST=tcp://127.0.0.1:4243

#PS1
PS1="\[\033[34m\][\[\033[m\]\[\033[35m\]\t\[\033[m\]\[\033[34m\]]\[\033[m\] [${debian_chroot:+($debian_chroot)}\u@\h \W]\$ "
#super toolish ps1
#PS1="┌─\[\033[34m\][\[\033[m\]\[\033[35m\]\t\[\033[m\]\[\033[34m\]]\[\033[m\]─\[\033[34m\][${debian_chroot:+($debian_chroot)}\u@\h]\[\033[m\]─\[\033[34m\][\w]\[\033[m\]\n└──[\[\033[32m\]\!\[\033[m\]] \$ "

#aliases
alias ll='ls --color -ltrha'
alias ls='ls --color'
alias glog='git log --oneline --name-status'
alias flog="vim $HOME/work/notes/$(date +%m-%d-%Y).log"
alias vundle_install="vim +PluginInstall +qall"
alias pps="ps -eLo user,pid,ppid,pcpu,psr,pmem,stat,start,etime,cmd"
alias i3l='i3lock -c 000000'
alias hugoserv='hugo server -v --watch --buildDrafts'

#functions
function gcommit() {
  git status -s
	echo 
  [ $# -gt 1 ] && {
	  commit_msg="$@"
	} || {
  	prompt=$(clr_green "commit msg> ")
    read -p "$prompt" commit_msg
	}
	[ $(echo $commit_msg| wc -w) -lt 1 ] && {
    echo "no commit message provided"
    return
  }
	git commit -a -m "$commit_msg"
	prompt=$(clr_green "push?(y/N)")
  read -n1 -p "$prompt" do_push
  [ "$do_push" == "y" ] && {
    git push
  }
}
function vimp() { /usr/bin/vim -p $@; }
function servethis() {
#  ls index.htm* 1> /dev/null 2>&1 || {
#    echo "no index found in current directory"
#    return
#  }
  cname="${PWD##*/}_nginx"
  echo "starting container ${cname}..."
  docker run -d \
             -p 80 \
             --name=${cname} \
             -v ~/.resources/nginx.conf:/etc/nginx/nginx.conf \
             -v ${PWD}:/srv/www \
             vektorlab/nginx:latest
  docker port ${cname}
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
function dusort() { du -hs $@/* | sort -h; }
function ttitle() { titletext=$@; }
function grepnotes() { find $HOME/work/notes/ -type f -iname "*log" -exec grep -Hi $@ {} \; ; }
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

wmfiles="${HOME}/.config/terminator/config \
         ${HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"

function wmfont() {
  [ $# != 1 ] && {
    echo "no arg provided"
    return
  }

  size=$1

  for file in $wmfiles; do

    [ ! -f ${file}-${size} ] && {
      echo "${file}-${size} not found, aborting"
      return
    }

    ln -nsvf ${file}-${size} $file

done
}

#autocomplete
complete -W "$(cat ~/.ssh/known_hosts | cut -f1 -d ':' | sed 's/\[//g;s/\]//g' | tr '\n' ' ')" ssh
complete -W "$(cat ~/.ssh/known_hosts | cut -f1 -d ':' | sed 's/\[//g;s/\]//g' | tr '\n' ' ')" scp
source ~/.docker-completion

source ~/.bashrcx
