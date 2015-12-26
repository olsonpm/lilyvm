#!/usr/bin/env sh


LOG_SRC=1

#---------#
# Imports #
#---------#

import constants


#------------------#
# Script Variables #
#------------------#

__log_res=


#------#
# Main #
#------#

log_warn () {
  __log_validate_message "${1}"
  local msg="${__log_res}"
  
  printf "%bWarning:%b %b\n" "${YELLOW}" "${RESET}" "${msg}" >&2
}

log_error () {
  __log_validate_message "${1}"
  local msg="${__log_res}"
  
  printf "%bError:%b %b\n" "${RED}" "${RESET}" "${msg}" >&2
}

log_fatal () {
  __log_validate_message "${1}"
  local msg="${__log_res}"
  
  __log_validate_errno "${2}"
  local errno="${__log_res}"
  
  printf "%bError:%b %b\n\n" "${RED}" "${RESET}" "${msg}" >&2
  printf "Please report a github issue so I can help you and others:\n" >&2
  printf "https://github.com/olsonpm/lilyvm/issues/new\n\n" >&2
  exit "${errno}"
}


#-------------#
# Helper Fxns #
#-------------#

__log_validate_message () {
  if [ -z "${1+x}" ] || [ "${1}" = "" ]; then
    printf "%bError:%b 'log_fatal' was called without a message argument.\n" "${RED}" "${RESET}" >&2
    exit 1
  fi
  
  __log_res="${1}"
}

__log_validate_errno () {
  local errno=1
  if [ "${1}" -eq "${1}" ] 2>/dev/null && [ ! "${1}" = "0" ]; then
    errno="${1}"
    if [ "${1}" -gt 255 ] || [ "${1}" -lt 1 ]; then
      printf "%bWarning:%b 'log_fatal' was called with an errno" "${YELLOW}" "${RESET}" >&1
      printf " greater than 255 or less than 1.  This may invoke an unexpected exit code.\n" >&1
    fi
    elif [ ! "${1}" = "" ]; then
    printf "%bError:%b 'log_fatal' was called with an invalid errno: '%b'.\n" "${RED}" "${RESET}" "${1}" >&2
    exit 1
  fi
  
  __log_res="${errno}"
}
