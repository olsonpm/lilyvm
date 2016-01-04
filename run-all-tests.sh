#! /usr/bin/env sh


#------------#
# Pre-Import #
#------------#

export ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
CONFIG_FILE="${ROOT_DIR}/.config"


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import test-utils


#------#
# Main #
#------#

tu_init
for aTest in "${ROOT_DIR}"/tests/*.sh; do
  . ${aTest}
done
tu_finalize
