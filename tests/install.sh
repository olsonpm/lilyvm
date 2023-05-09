#! /usr/bin/env sh


#---------#
# Imports #
#---------#

import remote-versions
import test-common


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/install.sh"

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

install_versions() {
  test_common_clean_versions_dir
  ${command} --version 2.18.2-1
  if [ $? != 0 ]; then
    exit 1
  fi
  local installedVersion="$(ls "${ROOT_DIR}/versions" | head -n1)"
  if [ "${installedVersion}" != "2.18.2-1" ]; then
    exit 1
  fi
}

#
# Since we can't know ahead of time what the latest versions will be, we have to write
#   a less-than-ideal test case ensuring
# 1) The installation exits with a zero status
# 2) The installed version matches the version returned by the library function
#

install_latest_stable() {
  test_common_clean_versions_dir
  ${command} --latest-stable
  if [ $? != 0 ]; then
    exit 1
  fi
  local installedVersion="$(ls "${ROOT_DIR}/versions" | head -n1)"
  remote_versions_get_latest_stable
  local latestStable="${remote_versions_res}"
  if [ "${installedVersion}" != "${latestStable}" ]; then
    exit 1
  fi
}

install_latest_unstable() {
  test_common_clean_versions_dir
  ${command} --latest-unstable
  if [ $? != 0 ]; then
    exit 1
  fi
  local installedVersion="$(ls "${ROOT_DIR}/versions" | head -n1)"
  remote_versions_get_latest_unstable
  local latestUnstable="${remote_versions_res}"
  if [ "${installedVersion}" != "${latestUnstable}" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "install_versions" \
"install --version" \
"install should succeed and the version should equal 2.18.2-1"

tu_assert_success "install_latest_stable" \
"install --latest-stable" \
"install should succeed and the version should match remote-version's latest_stable"

tu_assert_success "install_latest_unstable" \
"install --latest-unstable" \
"install should succeed and the version should match remote-version's latest_unstable"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
