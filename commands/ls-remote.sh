#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import constants
import log
import remote-versions
import local-versions


#------#
# Main #
#------#

ls_remote() {
  # handle options
  while getopts ":hs-:" opt; do
    case "${opt}" in
      -)
        case "${OPTARG}" in
          show-all)
            remote_versions_set_show_all 1
          ;;
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
      s)
        remote_versions_set_show_all 1
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
  
  remote_versions_get_versions
  printf "* = currently installed\n\n"
  for version in ${remote_versions_res}; do
    local_versions_has "${version}"
    if [ "${local_versions_res}" = "1" ]; then
      printf "%b\n" "${GREEN}${version}${RESET}*"
    else
      printf "%b\n" "${version}"
    fi
  done
  echo
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b List the versions" "${GREEN}" "${RESET}" >&$out
  printf " available for you to install.  By default\n it will only show stable" >&$out
  printf " versions but there is an option to show all.\n\n" >&$out
  printf "%bUsage:%b lilyvm ls-remote <options>\n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -s|--show-all     shows all versions instead of only stable\n" >&$out
  printf "  -h|--help         print this\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

ls_remote "${@}"
