#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import constants


#------#
# Main #
#------#

version() {
  local ver=$(head -n1 ${ROOT_DIR}/dist/version)
  printf "You are using lilyvm version: %b\n\n" "${GREEN}${ver}${RESET}"
}
