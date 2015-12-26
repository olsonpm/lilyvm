#!/usr/bin/env sh


#---------#
# Imports #
#---------#

import constants
import log


#------#
# Init #
#------#

USAGE_SRC=1


#------------------#
# Script Variables #
#------------------#

__usage_res=


#------#
# Main #
#------#

usage() {
  out=$1
  printf "%bDescription:%b A version manager for lilypond\n\n" "${GREEN}" "${RESET}"
  printf "%bUsage:%b lilyvm [options] <command>\n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help          print this\n" >&$out
  printf "  -v|--version       print version of lilyvm\n\n" >&$out
  printf "%bCommands%b\n" "${YELLOW}" "${RESET}" >&$out
  printf "  disable-colors     disable colors in terminal output - this preference is persisted\n" >&$out
  printf "  enable-colors      enable colors in terminal output - this preference is persisted\n" >&$out
  printf "  install            install a version of lilypond\n" >&$out
  printf "  ls                 list installed versions of lilypond\n" >&$out
  printf "  ls-remote          list hosted versions of lilypond available for install\n" >&$out
  printf "  uninstall          uninstall a version of lilypond\n" >&$out
  printf "  uninstall-lilyvm   uninstall lilyvm\n" >&$out
  printf "  update             update lilyvm to the latest version\n" >&$out
  printf "  use                set lilypond version for shell use\n" >&$out
  printf "  using              show current lilypond version\n\n" >&$out
  printf "To get help for a command, type %blilyvm <command> --help%b\n" "${YELLOW}" "${RESET}" >&$out
  printf "\n" >&$out
}


#-------------#
# Helper Fxns #
#-------------#

__usage_validate_out() {
  if [ -z "${1+x}" ] || [ "${1}" = "" ]; then
    log_fatal "'usage' was called without an argument."
  fi
  
  if [ "${1}" != "1" ] && [ "${1}" != "2" ]; then
    local msg="'usage' was called with an invalid argument: ${GREEN}${1}${RESET}"
    msg="${msg}\nAllowed: ${GREEN}1 | 2${RESET}"
    log_fatal "${msg}"
  fi
  
  __usage_res="${1}"
}
