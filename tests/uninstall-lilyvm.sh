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

uninstall_lilyvm() {
  test_common_install_lilyvm
  "${installDir}/.lilyvm/commands/uninstall-lilyvm.sh" -y
  if [ $? != 0 ] || [ -d "${installDir}/.lilyvm" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "uninstall_lilyvm" \
"uninstall-lilyvm -y" \
"The latest version should be installed inside the expected directory"


#----------#
# Clean Up #
#----------#

trapCmd
trap - EXIT
