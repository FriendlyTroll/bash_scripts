#!/bin/bash

# adapted from here
# https://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups

### AD-HOC CMDS: ###
# init repo:
# BORG_REPO=ssh://ante@syn415.local:22/~/borg_backup && borg init --encryption=keyfile $BORG_REPO
# !!! WARNING: Back up your keyfile (stored in .config/borg) somewhere safe! If you lose it you won't be able to decrypt the backups!!!

# list backups:
# BORG_REPO=ssh://ante@syn415.local:22/~/borg_backup borg list

# mount/unmount specific backup:
# BORG_REPO="ssh://ante@syn415.local:22/~/borg_backup::antisaPC-2020-03-03T16:11:40" && mkdir /tmp/borg && borg mount $BORG_REPO /tmp/borg
# borg umount /tmp/borg

### SCRIPT START ###
# or this to ask an external program to supply the passphrase:
# export BORG_PASSCOMMAND='pass show backup'

# Home directory
export HOME_DIR=/home/user
# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=ssh://ante@syn415.local:22/~/borg_backup
# Setting this, so you won't be asked for your repository passphrase:
export BORG_PASSPHRASE='123456'
# Setting this, to have access to the key for login into server
export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh
# Setting this for notify-osd below
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

/usr/bin/notify-send --icon=org.gnome.DejaDup "Starting backup"

# If the backup, running silently in the background, is rudely interrupted 
# by me rebooting my computer it will leave the write lock in place. It is 
# save to remove this lock because there is only one client uploading to the server.

/usr/bin/borg break-lock


# Backup the most important directories into an archive named after
# the machine this script is currently running on:

/usr/bin/borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression zlib,9            \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/home/*/.config/*/Cache'    \
    --exclude '/home/*/.gvfs'    \
    ::'{hostname}-{now}'            \
    $HOME_DIR                    \

backup_exit=$?

/usr/bin/notify-send --icon=org.gnome.DejaDup "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly, 4 monthly and 2 yearly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

/usr/bin/borg prune                          \
    --list                          \
    --prefix '{hostname}-'          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  4               \
    --keep-yearly   2               \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))


if [ ${global_exit} -eq 0 ]; then
    /usr/bin/notify-send --icon=org.gnome.DejaDup "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    /usr/bin/notify-send --icon=org.gnome.DejaDup "Backup and/or Prune finished with warnings"
else
    /usr/bin/notify-send --icon=org.gnome.DejaDup "Backup and/or Prune finished with errors"
fi

exit ${global_exit}
