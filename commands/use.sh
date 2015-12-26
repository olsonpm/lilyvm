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
  
  local_versions_set_current "${1}"
  printf "Now using version %b\n" "${GREEN}${1}${RESET}"
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
