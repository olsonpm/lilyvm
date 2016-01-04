#! /usr/bin/env sh


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/use.sh"
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
cp -r "${ROOT_DIR}/versions" "${ROOT_DIR}/versions.bak"
mkdir "${ROOT_DIR}/versions/2.18.1-1"
mkdir "${ROOT_DIR}/versions/2.18.2-1"
echo "using=2.18.2-1" > "${CONFIG_FILE}"
trapCmd() {
  rm -rf ${ROOT_DIR}/versions
  mv "${ROOT_DIR}/versions.bak" "${ROOT_DIR}/versions"
  mv "${CONFIG_FILE}.bak" "${CONFIG_FILE}"
}
trap trapCmd EXIT



#-------#
# Tests #
#-------#

use() {
  ${command} "2.18.1-1"
  local res="$(head -n1 "${CONFIG_FILE}")"
  if [ "${res}" != "using=2.18.1-1" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "use" \
"use" \
"The current lilypond version should change from 2.18.2-1 to 2.18.1-1"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
