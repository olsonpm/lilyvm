#! /usr/bin/env sh


OPTIONS_SRC=1

#---------#
# Imports #
#---------#

for option in "${ROOT_DIR}"/options/*; do
  . "${option}"
done
