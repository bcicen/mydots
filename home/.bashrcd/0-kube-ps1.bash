#!/bin/bash

# Kubernetes prompt helper for bash/zsh
# Displays current context and namespace

# Copyright 2019 Jon Mosco
#
#  Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Debug
[[ -n $DEBUG ]] && set -x

# Default values for the prompt
# Override these values in ~/.zshrc or ~/.bashrc
KUBE_PS1_BINARY="${KUBE_PS1_BINARY:-kubectl}"
KUBE_PS1_SYMBOL_DEFAULT='\u2388 '
KUBE_PS1_SEPARATOR="${KUBE_PS1_SEPARATOR-|}"
KUBE_PS1_SYMBOL_COLOR="${KUBE_PS1_SYMBOL_COLOR-blue}"
KUBE_PS1_CTX_COLOR="${KUBE_PS1_CTX_COLOR-red}"
KUBE_PS1_NS_COLOR="${KUBE_PS1_NS_COLOR-cyan}"
KUBE_PS1_BG_COLOR="${KUBE_PS1_BG_COLOR}"
KUBE_PS1_KUBECONFIG_CACHE="${KUBECONFIG}"
KUBE_PS1_DISABLE_PATH="${HOME}/.kube/kube-ps1/disabled"
KUBE_PS1_ENABLED=off
KUBE_PS1_LAST_TIME=0

# Determine our shell
if [ "${ZSH_VERSION-}" ]; then
  KUBE_PS1_SHELL="zsh"
elif [ "${BASH_VERSION-}" ]; then
  KUBE_PS1_SHELL="bash"
fi

_kube_ps1_init() {
  [[ -f "${KUBE_PS1_DISABLE_PATH}" ]] && KUBE_PS1_ENABLED=off
  [[ $PROMPT_COMMAND =~ _kube_ps1_update_cache ]] || PROMPT_COMMAND="_kube_ps1_update_cache;${PROMPT_COMMAND:-:}"
}

_kube_ps1_binary_check() {
  command -v $1 >/dev/null
}

_kube_ps1_split() {
  type setopt >/dev/null 2>&1 && setopt SH_WORD_SPLIT
  local IFS=$1
  echo $2
}

_kube_ps1_file_newer_than() {
  local mtime
  local file=$1
  local check_time=$2

  if [[ "${KUBE_PS1_SHELL}" == "zsh" ]]; then
    mtime=$(zstat -L +mtime "${file}")
  elif stat -c "%s" /dev/null &> /dev/null; then
    # GNU stat
    mtime=$(stat -L -c %Y "${file}")
  else
    # BSD stat
    mtime=$(stat -L -f %m "$file")
  fi

  [[ "${mtime}" -gt "${check_time}" ]]
}

_kube_ps1_update_cache() {
  local return_code=$?

  [[ "${KUBE_PS1_ENABLED}" == "off" ]] && return $return_code

  if ! _kube_ps1_binary_check "${KUBE_PS1_BINARY}"; then
    # No ability to fetch context/namespace; display N/A.
    KUBE_PS1_CONTEXT="BINARY-N/A"
    KUBE_PS1_NAMESPACE="N/A"
    return
  fi

  if [[ "${KUBECONFIG}" != "${KUBE_PS1_KUBECONFIG_CACHE}" ]]; then
    # User changed KUBECONFIG; unconditionally refetch.
    KUBE_PS1_KUBECONFIG_CACHE=${KUBECONFIG}
    _kube_ps1_get_context_ns
    return
  fi

  # kubectl will read the environment variable $KUBECONFIG
  # otherwise set it to ~/.kube/config
  local conf
  for conf in $(_kube_ps1_split : "${KUBECONFIG:-${HOME}/.kube/config}"); do
    [[ -r "${conf}" ]] || continue
    if _kube_ps1_file_newer_than "${conf}" "${KUBE_PS1_LAST_TIME}"; then
      _kube_ps1_get_context_ns
      return
    fi
  done

  return $return_code
}

_kube_ps1_get_context() {
  KUBE_PS1_CONTEXT="$(${KUBE_PS1_BINARY} config current-context 2>/dev/null)"
  # Set namespace to 'N/A' if it is not defined
  KUBE_PS1_CONTEXT="${KUBE_PS1_CONTEXT:-N/A}"

  if [[ ! -z "${KUBE_PS1_CLUSTER_FUNCTION}" ]]; then
    KUBE_PS1_CONTEXT=$($KUBE_PS1_CLUSTER_FUNCTION $KUBE_PS1_CONTEXT)
  fi
}

_kube_ps1_get_ns() {
  KUBE_PS1_NAMESPACE="$(${KUBE_PS1_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
  # Set namespace to 'default' if it is not defined
  KUBE_PS1_NAMESPACE="${KUBE_PS1_NAMESPACE:-default}"
}

_kube_ps1_get_context_ns() {
  # Set the command time
  if [[ "${KUBE_PS1_SHELL}" == "bash" ]]; then
    if ((BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 2)); then
      KUBE_PS1_LAST_TIME=$(printf '%(%s)T')
    else
      KUBE_PS1_LAST_TIME=$(date +%s)
    fi
  elif [[ "${KUBE_PS1_SHELL}" == "zsh" ]]; then
    KUBE_PS1_LAST_TIME=$EPOCHSECONDS
  fi

  _kube_ps1_get_context
  _kube_ps1_get_ns
}

# Set kube-ps1 shell defaults
_kube_ps1_init

_kubeon_usage() {
  cat <<"EOF"
Toggle kube-ps1 prompt on

Usage: kubeon [-g | --global] [-h | --help]

With no arguments, turn off kube-ps1 status for this shell instance (default).

  -g --global  turn on kube-ps1 status globally
  -h --help    print this message
EOF
}

_kubeoff_usage() {
  cat <<"EOF"
Toggle kube-ps1 prompt off

Usage: kubeoff [-g | --global] [-h | --help]

With no arguments, turn off kube-ps1 status for this shell instance (default).

  -g --global turn off kube-ps1 status globally
  -h --help   print this message
EOF
}

kubeon() {
  if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    _kubeon_usage
  elif [[ "${1}" == '-g' || "${1}" == '--global' ]]; then
    rm -f -- "${KUBE_PS1_DISABLE_PATH}"
  elif [[ "$#" -ne 0 ]]; then
    echo -e "error: unrecognized flag ${1}\\n"
    _kubeon_usage
    return
  fi

  KUBE_PS1_ENABLED=on
}

kubeoff() {
  if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    _kubeoff_usage
  elif [[ "${1}" == '-g' || "${1}" == '--global' ]]; then
    mkdir -p -- "$(dirname "${KUBE_PS1_DISABLE_PATH}")"
    touch -- "${KUBE_PS1_DISABLE_PATH}"
  elif [[ $# -ne 0 ]]; then
    echo "error: unrecognized flag ${1}" >&2
    _kubeoff_usage
    return
  fi

  KUBE_PS1_ENABLED=off
}

# Build our prompt
kube_ps1() {
  [[ "${KUBE_PS1_ENABLED}" == "off" ]] && return

  local KUBE_PS1

  # Prefix
  #KUBE_PS1+="("

  # Symbol
  #KUBE_PS1+="$(_clrRGB 105 200 247 "$KUBE_PS1_SYMBOL_DEFAULT") "
  KUBE_PS1+=" $(_clrRGB 127 233 208 "$KUBE_PS1_SYMBOL_DEFAULT") "

  # Context
  KUBE_PS1+="$(_clrRGB 255 105 133 ${KUBE_PS1_CONTEXT})"

  # Namespace
  KUBE_PS1+="$(_clrRGB 165 165 165 ':')"
  KUBE_PS1+="$(_clrRGB 127 233 208 ${KUBE_PS1_NAMESPACE})"

  KUBE_PS1+=" $(__ps1clr1 '›')"
  # Suffix
  #KUBE_PS1+=")"

  echo "${KUBE_PS1}"
}
