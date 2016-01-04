#! /usr/bin/env sh


#------#
# Init #
#------#

command="${ROOT_DIR}/commands/enable-colors.sh"
cp "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
trapCmd() {
  mv "${CONFIG_FILE}.bak" "${CONFIG_FILE}"
}
trap trapCmd EXIT
echo "colors_enabled=0" > "${CONFIG_FILE}"


#------#
# Main #
#------#

enable_colors() {
  ${command}
  local res="$(head -n1 "${CONFIG_FILE}")"
  if [ "${res}" != "colors_enabled=1" ]; then
    exit 1
  fi
}


#-----------#
# Run Tests #
#-----------#

tu_assert_success "enable_colors" \
"enable-colors" \
"colors_enabled setting should be set to 1"


#----------#
# Clean Up #
#----------#

trap - EXIT
trapCmd
