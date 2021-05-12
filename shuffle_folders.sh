#!/bin/bash
# https://askubuntu.com/questions/776298/a-script-for-copying-random-folders
SOURCE="path/to/source"
DESTINATION="path/to/destination"
# number of folders to copy
COUNT=25

rm -r "${DESTINATION}/"*
find "$SOURCE" -mindepth 2 -maxdepth 2 -type d|shuf -n $COUNT|xargs -d'\n' -I{} cp -r "{}" "$DESTINATION"

