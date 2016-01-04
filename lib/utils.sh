#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import log


#------------------#
# Script Variables #
#------------------#

# validation types
utils_va_NOT_EMPTY="NOT-EMPTY"
utils_va_ALL="${utils_va_NOT_EMPTY}"
utils_res=


#------#
# Main #
#------#

string_in_res=
string_in () {
  str="${1}"
  arr=${2}
  found=0
  set -f
  for element in ${arr}; do
    if [ "${str}" = "${element}" ]; then
      found=1
      break
    fi
  done
  set +f
  
  string_in_res=${found}
}

clear_last_line() {
  tput cuu 1 && tput el
}

run_command_with_status() {
  validate_arg -f "${utils_va_NOT_EMPTY}" "${1}"\
  "run_command_with_status requires a non-empty command"
  local command="${1}"
  
  validate_arg -f "${utils_va_NOT_EMPTY}" "${2}"\
  "run_command_with_status requires a non-empty status"
  local status="${2}"
  
  validate_arg -f "${utils_va_NOT_EMPTY}" "${3}"\
  "run_command_with_status requires a non-empty successStatus"
  local successStatus="${3}"
  
  __utils_display_status "${status}" &
  local pid="${!}"
  trap 'kill ${pid}; exit 1' EXIT
  eval ${command}
  kill ${pid}
  trap - EXIT
  clear_last_line
  printf "%b\n" "${successStatus}"
}

# this function should be ran in the background
__utils_display_status() {
  local status="${1}"
  local loadArr=". .. ..."
  
  while true; do
    for dots in ${loadArr}; do
      printf "%b\n" "${status}${dots}"
      sleep "0.5"
      clear_last_line
    done
  done
}

validate_arg() {
  local isFatal=0
  if [ "${1}" = "--fatal" ] || [ "${1}" = "-f" ]; then
    isFatal=1
    shift
  fi
  local validationType="${1}"
  local arg="${2}"
  local errMsg="${3}"
  string_in "${validationType}" "${utils_va_ALL}"
  if [ "${string_in_res}" = "0" ]; then
    local msg="validate_arg was called with an invalid validation type\n"
    msg="${msg}validation type: ${validationType}"
    log_fatal "${msg}"
  fi
  if [ "${errMsg}" = "" ]; then
    log_fatal "validate_arg was called with an empty errMsg"
  fi
  
  case "${validationType}" in
    "${utils_va_NOT_EMPTY}")
      utils_res=1
      if [ "${arg}" = "" ]; then
        utlis_res=0
      fi
    ;;
  esac
}
