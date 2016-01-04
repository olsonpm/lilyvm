#!/usr/bin/env sh


#---------#
# Imports #
#---------#

. "${ROOT_DIR}/lib/import.sh"
import log
import constants
import local-versions


#------------------#
# Script Variables #
#------------------#

__show_latest=0
__show_output='-s'
__curl_exit_code=
__latest=
__current=
__update_res=


#------#
# Main #
#------#

update() {
  # handle options
  while getopts ":hs-:" opt; do
    case "${opt}" in
      -)
        case "${OPTARG}" in
          help)
            usage 1
            exit 0
          ;;
          show-latest)
            __show_latest=1
          ;;
          show-output)
            __show_output=''
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
      s)
        __show_latest=1
      ;;
      o)
        __show_output=''
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
  
  __latest="$(curl ${__show_output} 'https://raw.githubusercontent.com/olsonpm/lilyvm/latest/dist/version')"
  __curl_exit_code="$?"
  __current="$(head -n1 "${ROOT_DIR}/dist/version")"
  __validate_versions
  if [ "${__show_latest}" = "0" ]; then
    __can_update
    if [ "${__update_res}" = "0" ]; then
      printf "You are already up to date at version %b\n\n" "${GREEN}${__current}${RESET}"
    else # [ "${__update_res}" = "1" ]; then
      __update
    fi
  else # [ "${__show_latest}" = "1" ]; then
    __show_latest
  fi
}

#-------------#
# Helper Fxns #
#-------------#

usage() {
  out=$1
  printf "%bDescription:%b Update lilyvm\n\n" "${GREEN}" "${RESET}" >&$out
  printf "%bUsage:%b lilyvm update [options] \n" "${GREEN}" "${RESET}" >&$out
  printf "%bOptions%b\n" "${YELLOW}" "${RESET}" >&$out
  printf "  -h|--help          print this\n" >&$out
  printf "  -s|--show-latest   Don't actually update lilyvm - just show the latest version\n" >&$out
  printf "  -o|--show-output   Show all curl output\n" >&$out
  printf "\n" >&$out
}

__update() {
  # remove lilyvm directories save for 'versions'
  rm -rf "${ROOT_DIR}/bin"
  rm -rf "${ROOT_DIR}/commands"
  rm -rf "${ROOT_DIR}/dist"
  rm -rf "${ROOT_DIR}/lib"
  rm -rf "${ROOT_DIR}/options"
  
  cd "${ROOT_DIR}"
  curl -Ls "https://github.com/olsonpm/lilyvm/archive/latest.tar.gz" | tar -xz
  mv "lilyvm-latest"/* "lilyvm-latest"/.* . 2>/dev/null
  
  printf "Successfully updated lilyvm to version %b" "${GREEN}${__latest}${RESET}"
}

__show_latest() {
  __can_update
  if [ "${__update_res}" = "0" ]; then
    printf "You are up to date at version %b\n\n" "${GREEN}${__latest}${RESET}"
  else # [ "${__update_res}" = "1" ]; then
    printf "The latest version is %b\n" "${GREEN}${__latest}${RESET}"
    printf "Your current version is %b\n\n" "${GREEN}${__current}${RESET}"
  fi
}

__can_update() {
  __update_res="$(expr "${__current}" \< "${__latest}")"
}

__validate_versions() {
  local appendError=''
  if [ "${__show_latest}" = "1" ] && [ "${__show_output}" = "" ]; then
    appendError=" - To show curl output, type ${YELLOW}lilyvm update --show-latest --show-output${RESET}"
  fi
  if [ "${__curl_exit_code}" != "0" ]; then
    log_error "Remote call to find latest version failed${appendError}"
    exit 1
  fi
  
  local gt="$(expr "${__current}" \> "${__latest}")"
  if [ "${gt}" = "1" ]; then
    local msg="Invalid State - The latest version is behind your version of lilyvm\n"
    msg="${msg}Latest: ${GREEN}${__latest}${RESET}\n"
    msg="${msg}Yours: ${GREEN}${__current}${RESET}\n\n"
    log_fatal "${msg}"
  fi
}


#-----#
# Run #
#-----#

update "${@}"
