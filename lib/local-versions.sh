#! /usr/bin/env sh


LOCAL_VERSIONS_SRC=1

#---------#
# Imports #
#---------#

import utils
import config-utils


#------------------#
# Script Variables #
#------------------#

local_versions_res=


#------#
# Main #
#------#

local_versions_get_current() {
  cu_get_value "${USING}"
  local_versions_res="${config_utils_result}"
}

local_versions_set_current() {
  local versionId="${1}"
  
  # validate
  local oldRes="${local_versions_res}"
  local_versions_has "${versionId}"
  if [ "${local_versions_res}" = "0" ]; then
    local msg="Invalid Input - cannot set version ${versionId} as current because"
    msg="${msg} it is not currently installed"
    log_fatal "${msg}"
  fi
  local_versions_res="${local_versions_res}"
  
  # no errors - good to go
  cu_set_name_value "${USING}" "${versionId}"
  
  local_versions_remove_shims
  
  # symlink new shims
  local lilyBinDir="${ROOT_DIR}/bin"
  local srcDir="${ROOT_DIR}/versions/${versionId}/bin"
  for binFile in "${srcDir}"/*; do
    baseBinFile="$(basename "${binFile}")"
    
    # We don't want the uninstall script to be exposed since lilyvm should take
    #   care of that
    if [ "${baseBinFile}" != "uninstall-lilypond" ]; then
      ln -s "${binFile}" "${lilyBinDir}/${baseBinFile}"
    fi
  done
  
  local_versions_res="${oldRes}"
}

local_versions_remove_shims() {
  local lilyBinDir="${ROOT_DIR}/bin"
  local baseBinFile=
  for binFile in "${lilyBinDir}"/*; do
    baseBinFile="$(basename "${binFile}")"
    if [ "${baseBinFile}" != "lilyvm" ]; then
      rm "${binFile}"
    fi
  done
}

local_versions_get() {
  local_versions_res="$(ls "${ROOT_DIR}/versions")"
}

local_versions_has() {
  local_versions_get
  string_in "${1}" "${local_versions_res}"
  local_versions_res="${string_in_res}"
}

local_versions_get_latest() {
  local_versions_res="$(ls "${ROOT_DIR}/versions" | tail -n1)"
}
