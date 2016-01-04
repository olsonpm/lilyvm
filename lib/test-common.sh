#! /usr/bin/env sh


TEST_COMMON_SRC=1


#------#
# Misc #
#------#

test_common_clean_versions_dir() {
  rm -rf "${ROOT_DIR}/versions"
  mkdir "${ROOT_DIR}/versions"
}


#----------------#
# Install Lilyvm #
#----------------#

# script variables
__test_common_OLD_PATH="${PATH}"
__test_common_expected_install_dir=

# if lilyvm exists on the path, then we need to temporarily remove that directory
#   from the path
test_common_install_lilyvm_init() {
  local installDir="${1}"
  lilyvmDir="$(which lilyvm | xargs dirname | sed -e 's/\./\\\./')"
  if [ "${lilyvmDir}" != "lilyvm not found" ]; then
    PATH="$(printf "%b" "${PATH}" | sed -e "s@:${lilyvmDir}@@")"
  fi
  
  # set up the installation directory
  __test_common_expected_install_dir="${installDir}"
  mkdir -p "${installDir}"
}

test_common_install_lilyvm_trap_cmd() {
  rm -rf "${__test_common_expected_install_dir}"
  PATH="${__test_common_OLD_PATH}"
}

test_common_install_lilyvm() {
  curl -s https://raw.githubusercontent.com/olsonpm/lilyvm/latest/dist/install.sh \
  | sh -s -- --install-dir "${__test_common_expected_install_dir}"
}
