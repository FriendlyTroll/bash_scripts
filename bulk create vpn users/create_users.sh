#!/bin/bash

# Create users.txt and passwords.txt in same directory first

# Read user and password
while read iuser ipasswd; do

  # Just print this for debugging.
  printf "\tCreating user: %s with password: %s\n" $iuser $ipasswd

  # Create the user with adduser (you can add whichever option you like).
  useradd -M -s /bin/false $iuser

  # Assign the password to the user.
  # Password is passed via stdin, *twice* (for confirmation).
  passwd $iuser <<< "$ipasswd"$'\n'"$ipasswd"

done < <(paste users.txt passwords.txt)
