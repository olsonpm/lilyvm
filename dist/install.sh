#!/usr/bin/env sh


#------#
# Init #
#------#

# Output is hard to read when it's smashed against the previous command, so
#   let's start with a blank line
echo


#-----------#
# Constants #
#-----------#

if [ "${1}" = '--no-color' ]; then
  RED=''
  GREEN=''
  YELLOW=''
  RESET=''
else
  RED='\033[31m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  RESET='\033[m'
fi



#------------#
# Validation #
#------------#

kernelName=$(uname -s)
if [ "${kernelName}" != 'Linux' ]; then
  printf "%bError:%b Unable to install.  Currently only Linux is supported.\n\n" "${RED}" "${RESET}" >&2
fi
machineHardwareName=$(uname -m)
if [ "${machineHardwareName}" != 'x86_64' ] && [ "${machineHardwareName}" != 'i686' ]; then
  printf "%bError:%b Unable to install.  Currently only 'x86_64' and 'i686'\n" "${RED}" "${RESET}" >&2
  printf "architectures are supported (as determined by 'uname -m').\n\n" >&2
fi
command -v lilyvm >/dev/null 2>&1 && {
  printf "%bError:%b lilyvm is already installed.  Use %blilyvm" "${RED}" "${RESET}" "${GREEN}" >&2
  printf " --update%b to get the latest version.\n\n" "${RESET}" >&2
  exit 1
}
if [ "${1}" != "" ]; then
  if [ "${1}" != "--install-dir" ]; then
    printf "%bError:%b The argument %b is invalid.\n\n" "${RED}" "${RESET}" "${YELLOW}${1}${RESET}" >&2
    exit 1
    elif [ ! -d "${2}" ]; then
    printf "%bError:%b The provided install-dir '%b' is not a valid directory.\n\n" "${RED}" "${RESET}" "${YELLOW}${2}${RESET}" >&2
    exit 1
  else # [ "${1}" = "--install-dir" ] && [ -d "${2}" ]; then
    HOME="${2}"
  fi
fi

if [ -e "${HOME}/.lilyvm" ]; then
  printf "%bError:%b path '%b/.lilyvm%b' already exists -" "${RED}" "${RESET}" "${GREEN}${HOME}" "${RESET}" >&2
  printf " yet you don't have lilyvm installed.\n  The installation directory name is not" >&2
  printf " configurable at this time, however you\n  may install lilyvm into a directory other" >&2
  printf " than home by temporarily setting the\n  HOME variable prior to installation. (e.g." >&2
  printf " export HOME=./; <install script>)\n\n" >&2
  
  exit 1
fi


#----------#
# Warnings #
#----------#

if [ -z "${HOME+x}" ]; then
  printf "%bWarning:%b environment variable HOME is not set." "${YELLOW}" "${RESET}"
  printf "  Installing lilyvm in the current directory.\n\n"
  export HOME="./"
fi

#------#
# Main #
#------#

rootDir=$(realpath ${HOME}/.lilyvm)

# safe to mkdir
mkdir ${rootDir} && cd ${rootDir}

mkdir bin versions

curl -s "https://raw.githubusercontent.com/olsonpm/lilyvm/latest/dist/lilyvm.tar.bz2" | tar -xj

# Initialize the config file
echo "colors_enabled=1" > .config

printf "%bSuccess!%b lilyvm has been installed.  To use lilyvm you need to add" "${GREEN}" "${RESET}"
printf " the following to your \nshell init script (.bashrc/.zshrc/<whateverrc>).\n\n"
printf "export PATH="'"'"%b/bin:\${PATH}"'"'" # Adds lilyvm to PATH\n\n" "${rootDir}"
printf "Once this is done, source the shell init script and you'll be good to go.\n\n"
