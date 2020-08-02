#!/bin/bash

# Temporary Colors of tput
GR="$(tput setaf 2)" #GREEN COLOR
YE="$(tput setaf 3)" # YELLOW COLOR
NL="$(tput sgr0)"    # RESET COLOR

#--------- Common Method --------#

# Update Source Update
aptUpdate() {
  sudo apt-get update --assume-yes
  printf  "%s Apt Source Updating Done.... %s \n" "$GR" "$NL"
}

# Upgrade
aptUpgrade() {
  sudo apt-get upgrade --assume-yes
  printf  "%s Apt Source Updating Done.... %s \n" "$GR" "$NL"
}

# --------------- Start Swap Storage Create ---------------#

aptUpdate  # Update Source
aptUpgrade  # Upgrade Source

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

# Swap Create Initialize
printf  "%s Do you want to create swap [Y/N] : %s" "$YE" "$NL"
read -r isSwap
if [ "$isSwap" = "Y" ] || [ "$isSwap" = "y" ]; then
   swapCreate
else
  printf  "%s Skipped. %s \n" "$GR" "$NL"
fi

# --------------- End Swap Storage Create ---------------#

# --------------- Start MySQL Setup ---------------#

# Getting MySQL deb file
# curl -OL https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
# Sources :
# https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#repo-qg-apt-repo-manual-setup
# https://geert.vanderkelen.org/2018/mysql8-unattended-dpkg/
# For Debian this line need to add sudo apt install -y dirmngr
# recv-keys 5072E1F5  this can be checked from https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#repo-qg-apt-repo-manual-setup
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
# @TODO -- We need to choose dynamically OS here (ubuntu/debian)
# here $(lsb_release -sc) will return buster for debian & bionic for ubuntu so we can get OS info from here
echo "deb http://repo.mysql.com/apt/ubuntu $(lsb_release -sc) mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list
aptUpdate

# For noninteractive installations of MySQL with the MySQL APT repository,
# answer the interactive questions asked by the server package by setting the relevant debconf variables

sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password yourPassword"
sudo debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password yourPassword"
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server


# --------------- End MySQL Setup ---------------#
