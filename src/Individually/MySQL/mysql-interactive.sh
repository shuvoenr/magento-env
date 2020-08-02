#!/bin/bash

# Temporary Colors of tput
GR="$(tput setaf 2)" #GREEN COLOR
YE="$(tput setaf 3)" # YELLOW COLOR
NL="$(tput sgr0)"    # RESET COLOR

# --------------- Start Swap Storage Create ---------------#

swapCreate() {
    printf  "%s How Many GB you want as Swap (Recommend Double of the Storage) :" "$YE"
    read -r swapRam
    printf  "%s Setting %s GB as swap memory. %s \n" "$GR" "$swapRam" "$NL"
    sudo fallocate -l "$swapRam"G /swapfile
    printf  "%s Allocate Done.%s \n" "$GR"  "$NL"
    sudo chmod 600 /swapfile
    printf  "%s Permission Changed. %s \n" "$GR"  "$NL"
    sudo mkswap /swapfile
    sudo swapon /swapfile
    printf  "%s Swap is up & Run. %s \n" "$GR"  "$NL"
    printf  "%s Making the swap space permanent.....%s \n" "$GR"  "$NL"
    sudo cp /etc/fstab /etc/fstab.bak
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    printf  "%s Done. %s \n" "$GR" "$NL"
}

# --------------- End Swap Storage Create ---------------#

# Update assume yes command
sudo apt-get update --assume-yes
printf  "%s Updating Done.... %s \n" "$GR" "$NL"

# Swap Create Initialize
printf  "%s Do you want to create swap [Y/N] : %s" "$YE" "$NL"
read -r isSwap
if [ "$isSwap" = "Y" ] || [ "$isSwap" = "y" ]; then
   swapCreate
else
  printf  "%s Skipped. %s \n" "$GR" "$NL"
fi
