#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import remote-versions
import test-common
import config-utils


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/uninstall.sh"
cp -r "${ROOT_DIR}/versions" "${ROOT_DIR}/versions.bak"
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"

trapCmd() {
  rm -rf ${ROOT_DIR}/versions
  mv "${ROOT_DIR}/versions.bak" "${ROOT_DIR}/versions"
  mv "${CONFIG_FILE}.bak" "${CONFIG_FILE}"
}
trap trapCmd EXIT


#-------#
# Tests #
#-------#

#
# Due to the static nature of lilypond's scripts (hardcoding file paths during installation),
#   It would be difficult to diff a newly installed instance of lilypond with a pre-installed
#   expected instance.  Therefore we are just going to make the same checks as the
#   latest-un/stable tests - meaning we check the install succeeded and that the version
#   matches what we expected.  If problems arise in the future due to this simplification,
#   we can address them then.
#

uninstall_lilypond() {
  test_common_clean_versions_dir
  echo "using=2.18.2-1" > "${CONFIG_FILE}"
  mkdir "${ROOT_DIR}/versions/2.18.1-1"
  mkdir "${ROOT_DIR}/versions/2.18.2-1"
  ${command} "2.18.2-1"
  cu_get_value "${USING}"
  local usingVersion="${config_utils_result}"
  if [ $? != 0 ] || [ -d "${ROOT_DIR}/versions/2.18.2-1" ] || [ "${usingVersion}" != "2.18.1-1" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "uninstall_lilypond" \
"uninstall 2.18.2-1" \
"installed version should no longer exist and 'current' should be set to 2.18.1-1"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
