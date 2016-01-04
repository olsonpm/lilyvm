#! /usr/bin/env sh


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/disable-colors.sh"
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
trapCmd() {
  mv "${CONFIG_FILE}.bak" "${CONFIG_FILE}"
}
trap trapCmd EXIT
echo "colors_enabled=1" > "${CONFIG_FILE}"


#-------#
# Tests #
#-------#

disable_colors() {
  ${command}
  local res="$(head -n1 "${CONFIG_FILE}")"
  if [ "${res}" != "colors_enabled=0" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "disable_colors" \
"disable-colors" \
"colors_enabled setting should be set to 0"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
