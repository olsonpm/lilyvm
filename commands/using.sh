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

using() {
  # handle options
  while getopts ":h-:" opt; do
    case "${opt}" in
      -)
        case "${OPTARG}" in
          help)
            __use_usage 1
            exit 0
          ;;
          *)
            log_error "Unknown option '--${OPTARG}'\n"
            __use_usage 2
            exit 1
          ;;
        esac
      ;;
      h)
        __use_usage 1
        exit 0
      ;;
      \?)
        log_error "Invalid option given: -${OPTARG}\n"
        __use_usage 2
        exit 1
      ;;
      :)
        log_error "Option -${OPTARG} requires an argument\n"
        __use_usage 2
        exit 1
      ;;
      *)
        log_error "Invalid option given: -${OPTARG}\n"
        __use_usage 2
        exit 1
      ;;
    esac
  done
  
  local_versions_get_current
  if [ "${local_versions_res}" = "" ]; then
    log_warn "You don't have any versions of lilypond installed\n"
  else # [ "${local_versions_res}" != "" ]; then
    printf "Currently using lilypond %b\n\n" "${GREEN}${local_versions_res}${RESET}"
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Show the lilypond version your shell points to\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm using [options] \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help         print usage\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

using "${@}"
