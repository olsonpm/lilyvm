#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import constants
import config-utils
import remote-versions


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/ls-remote.sh"
remote_versions_get_versions
libLineCountStable="$(printf "%b" "${remote_versions_res}" | wc -l)"
lineCountStable="$(${command} | wc -l)"

remote_versions_set_show_all 1
remote_versions_get_versions
libLineCountUnstable="$(printf "%b" "${remote_versions_res}" | wc -l)"
lineCountUnstable="$(${command} --show-all | wc -l)"


#------#
# Main #
#------#

#
# Since the number of versions available will increase, we can only assure a minimum
#   line count, and that more should show up when --show-all is specified.  Again,
#   this is a conscous test simplification that can be addressed if issues arise.
#

ls_remote_lib_at_least() {
  local atLeastTwelve="$(expr "${libLineCountStable}" \>= 12)"
  local atLeastEightyTwo="$(expr "${libLineCountUnstable}" \>= 82)"
  if [ "${atLeastTwelve}" != 1 ] || [ "${atLeastEightyTwo}" != 1 ]; then
    exit 1
  fi
}

ls_remote_lib_gt() {
  local gt="$(expr "${libLineCountUnstable}" \> "${libLineCountStable}")"
  if [ "${gt}" != 1 ]; then
    exit 1
  fi
}

ls_remote() {
  local expectedLineCountStable="$(( ${libLineCountStable} + 4 ))"
  local expectedLineCountUnstable="$(( ${libLineCountUnstable} + 4 ))"
  if [ "${lineCountStable}" != "${expectedLineCountStable}" ] || [ "${lineCountUnstable}" != "${expectedLineCountUnstable}" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "ls_remote_lib_at_least" \
"remote_versions_get_versions" \
"The number of returned versions should be at least a known number"

tu_assert_success "ls_remote_lib_gt" \
"remote_versions_get_versions" \
"More versions should return with --show-all flag"

tu_assert_success "ls_remote" \
"ls-remote" \
"There should be four more lines returned by the command compared to the lib"
