export PYTHONSTARTUP=~/.pythonrc
alias fssh='ssh -CXo GSSAPIAuthentication=no'
alias flog="vim $HOME/work/notes/$(date +%m-%d-%Y).log"
PROMPT_COMMAND='echo -ne "\033]0;"$titletext"\007"'
function ttitle() { titletext=$@; }
function grepnotes() { find $HOME/work/notes/ -type f -iname "*log" -exec grep -Hi $@ {} \; ; }
alias vundle_install="vim +BundleInstall +qall"
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
PATH=$PATH:$HOME/.gem/ruby/2.1.0/bin
