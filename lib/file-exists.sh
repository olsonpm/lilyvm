#! /usr/bin/env sh


FILE_EXISTS_SRC=1

#---------#
# Imports #
#---------#

import "log"


#------#
# Init #
#------#

__fe_debug_enabled=0
__fe_debug_print () {
  local msg="${1}"
  if [ "${__log_debug_enabled}" = 1 ]; then
    printf "debug: %b\n" "${msg}" >&1
  fi
}
__fe_debug_print "entering file_exists"


#-----#
# API #
#-----#

#-------------------------------
#
# Function: file_exists <file>
#
# Arguments:
#   <file> - May be a real file or a symlink and 'file_exists-res' should be set appropriately;
#
# Description: This function is meant to avoid the boiler plate code of checking the existence of a file
#   depending on all the usual scenerios.  If given a symlink, it will return whether the file which
#   symlink points to exists.  This function is most likely not comprehensive.
#
#-------------------------------


#-----------#
# Functions #
#-----------#

file_exists () {
  if [ -z ${1+x} ]; then
    log_fatal "'file_exists' was not given any arguments." 3
  fi
  
  local file="${1}"
  local tmp=0
  
  if [ ! -e "${file}" ]; then
    tmp=2
    elif [ -L "${file}" ] && [ ! -e "$(realpath "${file}")" ]; then
    tmp=1
  fi
  
  return $tmp
}

__fe_debug_print "exiting file_exists"
