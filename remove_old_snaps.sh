#!/bin/bash

# last update: 2019-04-11
# https://www.linuxuprising.com/2019/04/how-to-remove-old-snap-versions-to-free.html?ubureddit

# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu

snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done