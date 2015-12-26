#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import log
import constants
import local-versions


#------#
# Main #
#------#

ls_local() {
  # handle options
  while getopts ":hy-:" opt; do
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
  
  local_versions_get
  local installedVersions="${local_versions_res}"
  if [ "${installedVersions}" = "" ]; then
    printf "%bNo versions of lilypond installed%b\n\n" "${YELLOW}" "${RESET}"
  else
    local_versions_get_current
    local current="${local_versions_res}"
    for installed in ${installedVersions}; do
      if [ "${installed}" = "${current}" ]; then
        printf "%b <-- Current\n" "${GREEN}${installed}${RESET}"
      else
        printf "%b\n" "${installed}"
      fi
    done
    echo
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b List installed versions of lilypond\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm ls \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help         print this\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

ls_local "${@}"
