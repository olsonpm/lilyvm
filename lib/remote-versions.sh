#! /usr/bin/env sh


REMOTE_VERSIONS_SRC=1

#---------#
# Imports #
#---------#

import log


#------------------#
# Script Variables #
#------------------#

# exposed
remote_versions_show_all=0
remote_versions_res=

# private
__remote_versions_res=


#------#
# Main #
#------#

remote_versions_set_show_all() {
  if [ "${1}" = "0" ]; then
    remote_versions_show_all=0
    elif [ "${1}" = "1" ]; then
    remote_versions_show_all=1
  else
    local msg="Invalid Input - remote_versions_set_show_all was passed an "
    msg="${msg} invalid argument: ${1}"
    log_fatal "${msg}"
  fi
}

remote_versions_get_latest_stable() {
  local oldShowAll=${remote_versions_show_all}
  remote_versions_set_show_all "0"
  remote_versions_get_versions
  remote_versions_set_show_all "${oldShowAll}"
  remote_versions_res="$(printf "%b" "${remote_versions_res}" | tail -n1)"
}

remote_versions_get_latest_unstable() {
  local oldShowAll=${remote_versions_show_all}
  remote_versions_set_show_all "1"
  remote_versions_get_versions
  remote_versions_set_show_all "${oldShowAll}"
  remote_versions_res="$(printf "%b" "${remote_versions_res}" | tail -n1)"
}

remote_versions_get_versions() {
  __remote_versions_get_url
  local url="${__remote_versions_res}"
  if [ "${remote_versions_show_all}" = "0" ]; then
    useExpr='href="lilypond-[0-9]\.([2468]|[1-9][02468])\..*?'
  else # [ "${remote_versions_show_all}" = "1" ]; then
    useExpr='href="lilypond-[0-9].*?'
  fi
  
  remote_versions_res="$(curl -s "${url}" | grep -E "${useExpr}" | sed -r 's/^.*href="lilypond-([^/]*?)\.linux[^/]*?".*$/\1/')"
}

remote_versions_get_version_url() {
  local requestedVersion="${1}"
  
  __remote_versions_get_url
  local baseUrl="${__remote_versions_res}"
  
  __remote_versions_get_machine_hardware_postfix
  local postfix="${__remote_versions_res}"
  
  remote_versions_res="${baseUrl}lilypond-${requestedVersion}.linux-${postfix}.sh"
}


#-------------#
# Helper Fxns #
#-------------#

__remote_versions_get_url() {
  local urlBinary='http://download.linuxaudio.org/lilypond/binaries/linux-'
  __remote_versions_validate_kernel
  
  __remote_versions_get_machine_hardware_postfix
  local postfix="${__remote_versions_res}"
  
  __remote_versions_res="${urlBinary}${postfix}/"
}

__remote_versions_validate_kernel() {
  local kernelName=$(uname -s)
  if [ "${kernelName}" != 'Linux' ]; then
    local msg="Invalid State - 'uname -s' did not return Linux.\n"
    msg="${msg}  At the time of installation, this was not the case.\n"
    msg="${msg}  lilyvm does not\n  support your current kernel."
    
    log_fatal "${msg}"
  fi
}

__remote_versions_get_machine_hardware_postfix() {
  local res=
  local machineHardwareName=$(uname -m)
  if [ "${machineHardwareName}" = 'x86_64' ]; then
    res='64'
    elif [ "${machineHardwareName}" = 'i686' ]; then
    res='x86'
  else
    local msg="Invalid State - 'uname -m' returned neither x86_64 nor i686.\n"
    msg="${msg}  At the time of installation, this was not the case.\n"
    msg="${msg}  Regardless of what caused the change, lilyvm does not\n"
    msg="${msg}  support your current architecture."
    
    log_fatal "${msg}"
  fi
  
  __remote_versions_res="${res}"
}
