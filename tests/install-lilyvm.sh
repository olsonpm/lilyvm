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
trap test_common_install_lilyvm_trap_cmd EXIT


#------#
# Main #
#------#

install_lilyvm() {
  test_common_install_lilyvm
  
  if [ $? != 0 ] || [ ! -d "${installDir}/.lilyvm/dist" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "install_lilyvm" \
"lilyvm install script" \
"The latest version should be installed inside the expected directory"


#----------#
# Clean Up #
#----------#

test_common_install_lilyvm_trap_cmd
trap - EXIT
