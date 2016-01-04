#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import log
import local-versions


#------#
# Main #
#------#

use() {
  # handle options
  while getopts ":h-:" opt; do
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
  
  local requestedVersion="${1}"
  local_versions_has "${requestedVersion}"
  if [ "${local_versions_res}" = "0" ]; then
    local msg="You do not have version ${GREEN}${requestedVersion}${RESET} installed.\n"
    msg="${msg}Type ${YELLOW}lilyvm ls${RESET} to view your installed versions\n"
    log_error "${msg}"
    exit 1
  fi
  
  local_versions_get_current
  local current="${local_versions_res}"
  if [ "${current}" = "${requestedVersion}" ]; then
    log_warn "Already using version ${GREEN}${requestedVersion}${RESET}\n"
  else # [ "${current}" != "${requestedVersion}" ]; then
    local_versions_set_current "${requestedVersion}"
    printf "Now using version %b\n\n" "${GREEN}${requestedVersion}${RESET}"
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Set the lilypond version your shell points to\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm use [options] <version> \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help         print this\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

use "${@}"
