#! /usr/bin/env sh


IMPORT_SRC=1

#------#
# Init #
#------#

__import_dbg_print () {
  msg="${1}"
  if [ "${__import_dbg_enabled}" = 1 ]; then
    printf "debug: \n" "${msg}" >&1
  fi
}
__import_dbg_print "entering import"
__import_dbg_enabled=0
IMPORT_DIR="${ROOT_DIR}/lib"


#-----#
# API #
#-----#

#-------------------------------
#
# Public Constant: IMPORT_DIR
#
# Desciption: This holds the absolute directory name where imports are searched
#
#-------------------------------
#
# Function: import <file>
#
# Arguments:
#   <file> - The name of the file to import.  Currently the file is assumed to exist in
#     ${HOME}/library-fxns/*
#
# Description: This function allows scripts to easily import each other by assuming certain
#   naming conventions.
#
#-------------------------------


#-----------#
# Functions #
#-----------#

import () {
  local file="${1}"
  
  if [ ! -f "${IMPORT_DIR}/${file}.sh" ]; then
    local msg="Import '${1}' failed - file '${IMPORT_DIR}/${file}.sh' was not found\n"
    
    # The below code is copied from log-fatal.  Obviously we're unable to import it
    printf "%bError:%b\n\n" "${RED}" "${RESET} ${msg}" >&2
    printf "Please report a github issue so I can help you and others:\n" >&2
    printf "https://github.com/olsonpm/lilyvm/issues/new\n" >&2
    exit 1
  fi
  
  local src=$(basename "${file}" | tr '[:lower:]' '[:upper:]' | tr '-' '_' )"_SRC"
  eval src=\$$src
  if [ "${src}" != 1 ]; then
    if [ -f "${IMPORT_DIR}/${file}.sh" ]; then
      __import_dbg_print "importing ${IMPORT_DIR}/${file}.sh"
      . "${IMPORT_DIR}/${file}.sh"
    fi
  else
    __import_dbg_print "${IMPORT_DIR}/${file} has already been imported"
  fi
}

__import_dbg_print "exiting import"
