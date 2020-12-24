
source /usr/share/git/completion/git-prompt.sh

# prompt
export PS1_CONCAT=0
PS1_COLOR=$(_rgb 121 162 158)
__ps1clr1() { _clrRGB 117 222 241 $@; }
__ps1clr2() { _clrRGB 020 130 110 $@; }
__ps1clr3() { _clrRGB 000 240 120 $@; }
_PS1_BRKT="$(__ps1clr1 '›')"
_PS1_HOME="$(_clrRGB 224 217 133 '⌂')"
__ps1_pwd() {
  local p
  [[ "$PWD" == "$HOME" ]] && { echo -n "$_PS1_HOME"; return; }
  [[ "$PWD" =~ ^"$HOME"(/|$) ]] && p+="$_PS1_HOME "
  #echo -n "${p}$(_clrRGB 127 233 208 ${PWD##$HOME\/})" # teal
  echo -n "${p}$(_clrRGB 254 127 172 ${PWD##$HOME\/})" # pink
}

ps1t() {
  let PS1_CONCAT++
  if (($PS1_CONCAT % 2)); then
    PS1='$_PS1_BRKT $(__ps1_pwd)'
    PS1+='$(__git_ps1 " $_PS1_BRKT $(__ps1clr3 %s)")'
    PS1+='$(kube_ps1)'
    PS1+='\n \[$PS1_COLOR\]❭\[$CLR_RST\] '
  else
    PS1='›'
    PS1+='$_PS1_BRKT $(__ps1clr2 \W)$(__git_ps1 " $_PS1_BRKT $(__ps1clr3 %s)") '
  fi
}
ps1t

