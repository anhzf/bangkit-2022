#! /bin/bash

while : ; do
  read -p "According to the list which firewall-rules name to deletes? (space separated): " fw_names
  printf "You're about to deletes the following firewall-rules: \n $fw_names.\n"
  read -p "Continue? [y/n]: " want_to_continue

  if [ "$want_to_continue" == "y" ]; then
    echo "'$fw_names' deleted!"
    break
  fi
done