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


#------------------#
# Script Variables #
#------------------#

__install_type=
__install_res=
__install_version_id=
__install_show_output=0
__install_type_VERSION="version"
__install_type_LATEST_STABLE="latest-stable"
__install_type_LATEST_UNSTABLE="latest-unstable"


#------#
# Main #
#------#

install() {
  # handle options
  local msg=
  while getopts ":hv:su-:" opt; do
    case "${opt}" in
      -)
        case "${OPTARG}" in
          version)
            eval val=\$$OPTIND; OPTIND=$(( ${OPTIND} + 1 ))
            if [ "${val}" = "" ]; then
              log_error "option ${YELLOW}--version${RESET} requires an argument\n"
              usage 2
              exit 1
            fi
            
            __install_type="${__install_type_VERSION}"
            __install_version_id="${val}"
          ;;
          latest-stable)
            __install_type="${__install_type_LATEST_STABLE}"
          ;;
          latest-unstable)
            __install_type="${__install_type_LATEST_UNSTABLE}"
          ;;
          show-output)
            __install_show_output=1
          ;;
          help)
            usage 1
            exit 0
          ;;
          *)
            log_error "Unknown option ${YELLOW}--${OPTARG}${RESET}\n"
            usage 2
            exit 1
          ;;
        esac
      ;;
      h)
        usage 1
        exit 0
      ;;
      v)
        __install_type="${__install_type_VERSION}"
        __install_version_id="${OPTARG}"
      ;;
      s)
        __install_type="${__install_type_LATEST_STABLE}"
      ;;
      u)
        __install_type="${__install_type_LATEST_UNSTABLE}"
      ;;
      o)
        __install_show_output=1
      ;;
      \?)
        log_error "Invalid option given: ${YELLOW}-${OPTARG}${RESET}\n"
        usage 2
        exit 1
      ;;
      :)
        log_error "Option ${YELLOW}-${OPTARG}${RESET} requires an argument\n"
        usage 2
        exit 1
      ;;
      *)
        log_error "Invalid option given: ${YELLOW}-${OPTARG}${RESET}\n"
        usage 2
        exit 1
      ;;
    esac
  done
  
  # validate
  if [ "${__install_type}" = "" ]; then
    msg="'lilyvm install' must be called with either"
    msg="${msg} ${YELLOW}--version${RESET}, ${YELLOW}--latest-stable${RESET},\n  or"
    msg="${msg} ${YELLOW}--latest-unstable${RESET}\n"
    log_error "${msg}"
    exit 1
  fi
  
  # no errors - good to go
  case "${__install_type}" in
    "${__install_type_LATEST_STABLE}")
      remote_versions_get_latest_stable
      __install_version_id="${remote_versions_res}"
    ;;
    "${__install_type_LATEST_UNSTABLE}")
      remote_versions_get_latest_unstable
      __install_version_id="${remote_versions_res}"
    ;;
  esac
  
  __install_version
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Install a version of lilyvm" "${GREEN}" "${RESET}" >&$out
  printf " dependent upon the options supplied\n\n" >&$out
  printf "%bUsage:%b lilyvm install <options>\n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -v|--version <version>    install the specified version\n" >&$out
  printf "  -s|--latest-stable        install the latest stable version\n" >&$out
  printf "  -u|--latest-unstable      install the latest unstable version\n" >&$out
  printf "  -h|--help                 print this\n" >&$out
  printf "\n" >&$out
}

__install_version() {
  __install_validate_version
  local requestedVersion="${__install_version_id}"
  remote_versions_get_version_url "${requestedVersion}"
  local installScriptUrl="${remote_versions_res}"
  
  local tempInstallScript="${ROOT_DIR}/temp-install-script.sh"
  
  printf "Downloading install script\n"
  curl -# -o "${tempInstallScript}" "${installScriptUrl}"
  echo
  
  chmod 774 "${tempInstallScript}"
  local installDir="${ROOT_DIR}/versions/${requestedVersion}"
  mkdir "${installDir}"
  local appendError=""
  
  if [ "${__install_show_output}" = "0" ]; then
    run_command_with_status "${tempInstallScript} --prefix ${installDir} --batch >/dev/null 2>&1"\
    "Installing" "Install script executed"
    
    appendError=" - run with option ${YELLOW}--show-output${RESET} to see the lilypond install output"
  else # [ "${__install_show_output}" = "1" ]; then
    run_command_with_status "${tempInstallScript} --prefix ${installDir} --batch"\
    "Installing" "Install script executed"
  fi
  echo
  rm -rf "${tempInstallScript}"
  if [ "$?" != "0" ]; then
    log_error "Install failed${appendError}"
    exit 1
  else # [ "$?" = "0" ]; then
    printf "Lilypond version %b was successfully installed\n\n" "${GREEN}${requestedVersion}${RESET}"
  fi
  
  local_versions_get_current
  local usingVersion="${local_versions_res}"
  if [ "${usingVersion}" = "" ]; then
    local_versions_set_current "${requestedVersion}"
    printf "Since this is your first install, the current version is now set to this one.\n"
    printf "  Should you decide to install more versions, you may change your current version \n"
    printf "  via %b\n\n" "${YELLOW}lilyvm use <version>${RESET}"
  fi
}

__install_validate_version() {
  local requestedVersion="${__install_version_id}"
  local_versions_has "${requestedVersion}"
  if [ "${local_versions_res}" = "1" ]; then
    log_warn "Not installing - version ${GREEN}${requestedVersion}${RESET} is already installed\n"
    exit 1
  fi
  
  remote_versions_set_show_all "1"
  remote_versions_get_versions
  local availableVersions="${remote_versions_res}"
  string_in "${requestedVersion}" "${availableVersions}"
  if [ "${string_in_res}" = "0" ]; then
    local msg="Not installing - The version '${requestedVersion}' is not in the list\n"
    msg="${msg}  of available versions.  The list can be shown via 'lilyvm ls-remote --show-all'.\n"
    log_error "${msg}"
    exit 1
  fi
}


#-----#
# Run #
#-----#

install "${@}"
