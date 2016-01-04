#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import constants


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/using.sh"
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
trapCmd() {
  mv "${CONFIG_FILE}.bak" "${CONFIG_FILE}"
}
trap trapCmd EXIT



#-------#
# Tests #
#-------#

using() {
  printf "colors_enabled=0\nusing=2.18.2-1\n" > "${CONFIG_FILE}"
  local using1="$(${command}; echo x)"
  printf "colors_enabled=0\nusing=2.18.1-1\n" > "${CONFIG_FILE}"
  local using2="$(${command}; echo x)"
  using1="${using1%x}"
  using2="${using2%x}"
  if [ "${using1}" != "Currently using lilypond 2.18.2-1${nl}${nl}" ] \
  || [ "${using2}" != "Currently using lilypond 2.18.1-1${nl}${nl}" ]; then
    
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "using" \
"using" \
"The current lilypond version should change from 2.18.2-1 to 2.18.1-1"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
