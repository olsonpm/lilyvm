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

disable_colors() {
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
  if [ "${colorsEnabled}" = "0" ]; then
    log_warn "colors are already disabled"
  else # [ "${colorsEnabled}" = "1" ]; then
    cu_set_name_value "${COLORS_ENABLED}" "0"
    printf "Colors have been disabled\n\n"
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Disables colors in lilyvm output\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm disable-colors \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -h|--help         print this\n" >&$out
  printf "\n" >&$out
}


#-----#
# Run #
#-----#

disable_colors "${@}"
