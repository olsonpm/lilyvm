#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import constants
import config-utils


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/ls-local.sh"
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
cp -r "${ROOT_DIR}/versions" "${ROOT_DIR}/versions.bak"
trapCmd() {
  rm -rf ${ROOT_DIR}/versions
  mv "${ROOT_DIR}/versions.bak" "${ROOT_DIR}/versions"
  mv "${CONFIG_FILE}.bak" "${CONFIG_FILE}"
}
trap trapCmd EXIT
cu_set_name_value "${COLORS_ENABLED}" "0"


#------#
# Main #
#------#

ls_local_no_versions() {
  clean_versions_dir
  local res="$(${command}; echo x)"
  res="${res%x}"
  if [ "${res}" != "No versions of lilypond installed${nl}${nl}" ]; then
    exit 1
  fi
}

ls_local_single() {
  clean_versions_dir
  mkdir "${ROOT_DIR}/versions/2.18.2-1"
  local res="$(${command}; echo x)"
  res="${res%x}"
  if [ "${res}" != "2.18.2-1${nl}${nl}" ]; then
    exit 1
  fi
}

ls_local_two() {
  clean_versions_dir
  mkdir "${ROOT_DIR}/versions/2.18.1-1"
  mkdir "${ROOT_DIR}/versions/2.18.2-1"
  local res="$(${command}; echo x)"
  res="${res%x}"
  if [ "${res}" != "2.18.1-1${nl}2.18.2-1${nl}${nl}" ]; then
    exit 1
  fi
}



#-------------#
# Helper Fxns #
#-------------#

clean_versions_dir() {
  rm -rf "${ROOT_DIR}/versions"
  mkdir "${ROOT_DIR}/versions"
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "ls_local_no_versions" \
"ls-local" \
"ls_local should show that no versions are installed"

tu_assert_success "ls_local_single" \
"ls-local" \
"ls_local should show a single version: 2.18.2-1"

tu_assert_success "ls_local_two" \
"ls-local" \
"ls_local should show two versions: 2.18.1-1 and 2.18.2-1"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
