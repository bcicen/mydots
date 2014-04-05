export PYTHONSTARTUP=~/.pythonrc
alias fssh='ssh -CXo GSSAPIAuthentication=no'
alias flog="vim /home/bradley/work/notes/$(date +%m-%d-%Y).log"
PROMPT_COMMAND='echo -ne "\033]0;"$titletext"\007"'
function ttitle() { titletext=$@; }
alias vundle_install="vim +BundleInstall +qall"
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
