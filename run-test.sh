#! /usr/bin/env sh


export ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
CONFIG_FILE="${ROOT_DIR}/.config"

#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import log
import test-utils


#------#
# Main #
#------#

if [ ! -f "${ROOT_DIR}/tests/${1}.sh" ]; then
  log_error "Argument passed doesn't match a file in the tests directory (sans extension)"
  exit 1
fi

tu_init
. ${ROOT_DIR}/tests/${1}.sh
tu_finalize
