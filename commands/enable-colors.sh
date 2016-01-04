#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import log
import config-utils


#------#
# Main #
#------#

enable_colors() {
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
  
  colorsEnabled="$(cu_get_value "${COLORS_ENABLED}")"
  if [ "${colorsEnabled}" = "1" ]; then
    log_warn "colors are already enabled"
  else # [ "${colorsEnabled}" = "0" ]; then
    cu_set_name_value "${COLORS_ENABLED}" "1"
    printf "Colors have been %benabled%b\n\n" "${GREEN}" "${RESET}"
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Enables colors in lilyvm output\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm enable-colors \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help         print this\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

enable_colors "${@}"
