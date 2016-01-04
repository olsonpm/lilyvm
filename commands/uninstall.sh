#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import constants
import log
import config-utils
import remote-versions
import local-versions
import utils


#------#
# Main #
#------#

uninstall() {
  # handle options
  while getopts ":hv:-:" opt; do
    case "${opt}" in
      -)
        case "${OPTARG}" in
          help)
            usage 1
            exit 0
          ;;
          *)
            log_error "Unknown option '--${OPTARG}'\n"
            usage 2
            exit 1
          ;;
        esac
      ;;
      h)
        usage 1
        exit 0
      ;;
      \?)
        log_error "Invalid option given: -${OPTARG}\n"
        usage 2
        exit 1
      ;;
      :)
        log_error "Option -${OPTARG} requires an argument\n"
        usage 2
        exit 1
      ;;
      *)
        log_error "Invalid option given: -${OPTARG}\n"
        usage 2
        exit 1
      ;;
    esac
  done
  
  local versionId="${1}"
  
  # validate
  local_versions_has "${versionId}"
  local isInstalled="${local_versions_res}"
  if [ "${isInstalled}" = "0" ]; then
    log_warn "Not uninstalling - The version '${versionId}' is not installed\n"
    exit 1
  fi
  
  # no errors - good to go
  rm -rf "${ROOT_DIR}/versions/${versionId}"
  printf "Lilypond version %b was successfully uninstalled\n\n" "${GREEN}${versionId}${RESET}"
  
  # check to make sure the user's current version is not the uninstalled one
  local_versions_get_current
  local usingVersion="${local_versions_res}"
  if [ "${usingVersion}" = "${versionId}" ]; then
    local_versions_get_latest
    if [ "${local_versions_res}" = '' ]; then
      log_warn "You deleted your last version of lilypond\n"
      cu_set_name_value "${USING}" ''
      local_versions_remove_shims
    else
      local_versions_set_current "${local_versions_res}"
      printf "Current version changed from the one you just uninstalled to "
      printf "%b\n  which is the latest version" "${GREEN}${local_versions_res}${RESET}"
      printf " you have.  Remember you can change\n  the current version via "
      printf "%b\n\n" "${YELLOW}lilyvm use <version>${RESET}"
    fi
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Uninstall a version of lilypond.\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm uninstall <options> <version>\n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help                 print this\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

uninstall "${@}"
