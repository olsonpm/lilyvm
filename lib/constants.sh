#!/usr/bin/env sh


CONSTANTS_SRC=1

#---------#
# Imports #
#---------#

import config-utils


#------#
# Main #
#------#

# config
COLORS_ENABLED="colors_enabled"
USING="using"

# misc
nl='
'

# initialize colors
cu_get_value "${COLORS_ENABLED}"
colorsEnabled="${config_utils_result}"

if [ "${colorsEnabled}" = "1" ]; then
  RED="\033[31m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  CYAN="\033[34m"
  MAGENTA="\033[35m"
  RESET="\033[m"
else # [ "${colorsEnabled}" = "0" ]; then
  RED=""
  GREEN=""
  YELLOW=""
  CYAN=""
  MAGENTA=""
  RESET=""
fi
