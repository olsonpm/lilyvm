#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import log


#------------------#
# Script Variables #
#------------------#

__uninstall_lilyvm_prompt=1


#------#
# Main #
#------#

uninstall_lilyvm() {
  # handle options
  while getopts ":hy-:" opt; do
    case "${opt}" in
      -)
        case "${OPTARG}" in
          yes)
            eval val=\$$OPTIND; OPTIND=$(( ${OPTIND} + 1 ))
            __uninstall_lilyvm_remove_prompt
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
      y)
        __uninstall_lilyvm_remove_prompt
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
  
  local shouldUninstall='y'
  if [ "${__uninstall_lilyvm_prompt}" = "1" ]; then
    printf "Are you sure you want to uninstall lilyvm? %b[y/N]%b: " "${GREEN}" "${RESET}"
    read shouldUninstall
    echo
    shouldUninstall=$(echo ${shouldUninstall} | tr '[:upper:]' '[:lower:]')
  fi
  if [ "${shouldUninstall}" = 'y' ]; then
    rm -rf "${ROOT_DIR}"
    
    if [ "$?" = 0 ]; then
      printf "%b'%b'%b has been deleted.\n\nTo complete the uninstall," "${YELLOW}" "${ROOT_DIR}" "${RESET}"
      printf " you must remove the path modification you made\n  upon installation. The line should be"
      printf " found in your shell init script,\n  and resemble the following:\n\n"
      printf "export PATH="'"'"%b/bin\${PATH}"'"'" # Adds lilyvm to PATH\n\n" "${ROOT_DIR}"
    fi
  else
    printf "lilyvm was not harmed\n\n"
  fi
}


#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Uninstall lilyvm" "${GREEN}" "${RESET}" >&$out
  printf " along with all its versions of lilypond.\n\n" >&$out
  printf "%bUsage:%b lilyvm uninstall-lilyvm \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}">&$out
  printf "  -y|--yes          skips prompt\n" >&$out
  printf "  -h|--help         print this\n" >&$out
  printf "\n" >&$out
}

__uninstall_lilyvm_remove_prompt() {
  __uninstall_lilyvm_prompt=0
}


#-----#
# Run #
#-----#

uninstall_lilyvm "${@}"
