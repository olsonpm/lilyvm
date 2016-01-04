#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import test-common
import constants


#------#
# Init #
#------#

installDir="${ROOT_DIR}/tests/expected/install-lilyvm"
latestVersion="$(curl -s 'https://raw.githubusercontent.com/olsonpm/lilyvm/latest/dist/version')"
test_common_install_lilyvm_init "${installDir}"
OLD_ROOT_DIR="${ROOT_DIR}"
ROOT_DIR="${installDir}/.lilyvm"
trapCmd() {
  test_common_install_lilyvm_trap_cmd
  ROOT_DIR="${OLD_ROOT_DIR}"
}
trap trapCmd EXIT


#------#
# Main #
#------#

update_lilyvm_show_latest() {
  test_common_install_lilyvm
  echo "enable_colors=0" > "${installDir}/.lilyvm/.config"
  local output="$("${installDir}/.lilyvm/commands/update.sh" --show-latest; echo x)"
  output="${output%x}"
  rm -rf "${installDir}/.lilyvm"
  printf "%b" "${output}"
  if [ "${output}" != "You are up to date at version ${latestVersion}${nl}${nl}" ]; then
    exit 1
  fi
}

update_lilyvm() {
  test_common_install_lilyvm
  echo "enable_colors=0" > "${installDir}/.lilyvm/.config"
  echo "v0.0.0" > "${installDir}/.lilyvm/dist/version"
  "${installDir}/.lilyvm/commands/update.sh"
  local updatedVersion="$(head -n1 "${installDir}/.lilyvm/dist/version")"
  rm -rf "${installDir}/.lilyvm"
  if [ $? != 0 ] || [ "${updatedVersion}" != "${latestVersion}" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "update_lilyvm_show_latest" \
"update --show-latest" \
"The latest available version should be printed"

tu_assert_success "update_lilyvm" \
"update" \
"Lilyvm should update to the latest version"


#----------#
# Clean Up #
#----------#

trapCmd
trap - EXIT
