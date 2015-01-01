export PYTHONSTARTUP=~/.pythonrc
export GOPATH=~/gocode
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
PATH=$PATH:$HOME/.gem/ruby/2.1.0/bin

#PS1
PS1="\[\033[34m\][\[\033[m\]\[\033[35m\]\t\[\033[m\]\[\033[34m\]]\[\033[m\] [${debian_chroot:+($debian_chroot)}\u@\h \W]\$ "
#super toolish ps1
#PS1="┌─\[\033[34m\][\[\033[m\]\[\033[35m\]\t\[\033[m\]\[\033[34m\]]\[\033[m\]─\[\033[34m\][${debian_chroot:+($debian_chroot)}\u@\h]\[\033[m\]─\[\033[34m\][\w]\[\033[m\]\n└──[\[\033[32m\]\!\[\033[m\]] \$ "

#aliases
alias fssh='ssh -CXo GSSAPIAuthentication=no'
alias flog="vim $HOME/work/notes/$(date +%m-%d-%Y).log"
alias vundle_install="vim +BundleInstall +qall"

#functions
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
            echo "usage: tsdocker <hostname> dockercommandto run"
            echo "OR tsdocker set <hostname>"
            ;;
        *)
            h="$1"
            shift
            docker -H "tcp://$h:4243" $@
            ;;
    esac
}
