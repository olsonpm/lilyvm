#! /usr/bin/env sh


CONFIG_UTILS_SRC=1

#---------#
# Imports #
#---------#

import file-exists
import log


#------#
# Init #
#------#

__cu_debug_enabled=0
__cu_debug_print () {
  local msg="${1}"
  if [ "${__log_debug_enabled}" = 1 ]; then
    printf "debug: %b\n" "${msg}" >&1
  fi
}
__cu_debug_print "entering config_utils"


#-----#
# API #
#-----#

#-------------------------------
#
# Function: cu_get_value <name> [file=<file>] [throw-error=<true>]
#
# Arguments:
#   <name> - The name of the config option
#   [file] - The name of the file to get the value from.
#   [throw-error ^false] - If this argument exists, the function will first validate whether the
#     argument is equal to "true".  If the string doesn't match, the function
#     exits and logs to stderr.  If it is set properly, this function will
#     throw an error if a config option with name=<name> was not found.
#
# Description: Gets the value of the config option with name=<name>.  Will optionally throw an error
#   if no config option was found.
#
# Sets:
#   config_utils_result - Set to the value of the config option matching <name>  If [error] wasn't provided
#     and no config option was found, then this is set to an empty string.
#
#-------------------------------
#
# Function: cu_set_name_value <name> <value> [file]
#
# Arguments:
#   <name> - The name of the config option
#   <value> - The value to be mapped to the above name
#   [file] - If 'cu_persistent_file' is not set, then this argument is required.  It tells
#     the function which file to set the config option for.
#
# Description: First checks the config file for the name.  If the name exists, then it replaces its
#   current value with the given value.  Otherwise it appends the option to the end of
#   the file.
#
#-------------------------------
#
# Function: cu_remove_name <name> [file]
#
# Arguments:
#   <name> - The name of the config option
#   [file] - If 'cu_persistent_file' is not set, then this argument is required.  It tells
#     the function which file to remove the config option from.
#
# Description: If the name exists, then that line is killed (moves all lines below it up one)
#
#-------------------------------
#
# Function: cu_set_persistent_file <file>
#
# Arguments:
#   <file> - Name of the file
#
# Description: This allows a script to only specify its configuration file once at the beginning so
#   the above functions don't require it for every call.
#
# Sets:
#   cu_persistent_file - Sets to the given file name
#
#-------------------------------


#------------------#
# Script Variables #
#------------------#

CONFIG_PATH="${ROOT_DIR}/.config"
cu_persistent_file="${CONFIG_PATH}"
config_utils_result=
__config_utils_res=


#------------#
# Exit codes #
#------------#

#api methods
__cu_inv_argument=1
__cu_name_not_found=2
__cu_val_not_given=3

#helper methods
__cu_inv_name=100
__cu_file_not_provided=101
__cu_file_not_exist=102
__cu_inv_opt_file=103
__cu_need_opt_file=104
__cu_inv_throw=105


#-----------#
# Functions #
#-----------#

cu_get_value () {
  __cu_validate_name "${1}"
  local name="${__config_utils_res}"
  local file=
  local throw=
  
  while [ "$#" != 1 ]; do
    if [ ! ${2##file=*} ]; then
      file="$(printf "%b" "${2}" | sed -e 's/^file=\(.*\)$/\1/g')"
      __cu_validate_optional_file "${file}"
      file="${__config_utils_res}"
      elif [ ! ${2##throw-error=*} ]; then
      throw="$(printf "%b" "${2}" | sed -e 's/^throw-error=\(.*\)$/\1/g')"
      __cu_validate_throw "${throw}"
      throw="${__config_utils_res}"
    else #improper argument supplied
      log_fatal "Invalid argument '${2}' was supplied." ${__cu_inv_argument}
    fi
    
    shift
  done
  
  if [ "${file}" = "" ] && [ "${cu_persistent_file}" = "" ]; then
    log_fatal "file argument is needed if 'cu_persistent_file' is not set" ${__cu_need_opt_file}
    elif [ "${file}" = "" ]; then
    file="${cu_persistent_file}"
  fi
  
  result=$(sed -n -e "s/^${name}=\(.*\)/\1/p" "${file}")
  if [ "${throw}" = "true" ] && [ "${result}" = "" ]; then
    log_fatal "Could not find name: '${name}' in file: '${file}'." ${__cu_name_not_found}
  fi
  config_utils_result="${result}"
}

cu_set_name_value () {
  __cu_validate_name "${1}"
  local name="${__config_utils_res}"
  
  if [ -z "${2+x}" ]; then
    log_fatal "<value> wasn't provided" ${__cu_val_not_given}
  fi
  local val="${2}"
  
  __cu_validate_optional_file "${3}"
  local file="${__config_utils_res}"
  
  # find name in file
  local found=$(sed -n -e "/^${name}=/p" "${file}")
  
  # if found is not empty (and thus the name _was_ found)
  if [ "${found}" != "" ]; then
    local sedName="$(printf "%b" "${name}" | sed -e 's/\//\\\//g')"
    local sedVal="$(printf "%b" "${val}" | sed -e 's/\//\\\//g')"
    sed -i "s/${sedName}=.*/${sedName}=${sedVal}/" "${file}"
  else
    printf "%b=%b\n" "${name}" "${val}" >> "${file}"
  fi
}

cu_remove_name () {
  __cu_validate_name "${1}"
  local name="${__config_utils_res}"
  
  local sedName="$(printf "%b" "${name}" | sed -e 's/\//\\\//g')"
  
  __cu_validate_optional_file "${2}"
  local file="${__config_utils_res}"
  
  sed -i "/${sedName}=/d" "${file}" 1>/dev/null
}

cu_set_persistent_file () {
  __cu_validate_file "${1}"
  cu_persistent_file="${__config_utils_res}"
}

#------------------#
# Helper Functions #
#------------------#

__cu_validate_name () {
  if [ "${1}" = "" ]; then
    log_fatal "<name> wasn't provided" ${__cu_inv_name}
  fi
  
  __config_utils_res="${1}"
}

__cu_validate_file () {
  if [ "${1}" = "" ]; then
    log_fatal "<file> wasn't provided" ${__cu_file_not_provided}
    elif ! file_exists "${1}"; then
    log_fatal "file: '${1}' doesn't exist" ${__cu_file_not_exist}
  fi
  
  __config_utils_res="$(realpath "${1}")"
}

__cu_validate_optional_file () {
  local file=
  local tmpError=
  
  # error cases
  if [ "${1}" != "" ] && ! file_exists "${1}"; then
    log_fatal "file argument '${1}' is not valid" ${__cu_inv_opt_file}
    elif [ "${1}" = "" ] && [ "${cu_persistent_file}" = "" ]; then
    log_fatal "file argument is needed if 'cu_persistent_file' is not set" ${__cu_need_opt_file}
  fi
  
  if [ "${1}" = "" ]; then
    file="${cu_persistent_file}"
  else # passed in file must be valid
    file="$(realpath "${1}")"
  fi
  
  __config_utils_res="${file}"
}

__cu_validate_throw () {
  local result="false"
  if [ "${1}" = "true" ]; then
    result="true"
    elif [ "${1}" != "" ] && [ "${1}" != "false" ]; then
    local msg="[throw-error] was supplied but is invalid"
    msg="${msg} (given: '${1}').  This parameter must be 'true' or 'false'."
    log_fatal "${msg}" ${__cu_inv_throw}
  fi
  
  __config_utils_res="${result}"
}

__cu_debug_print "exiting config_utils"
