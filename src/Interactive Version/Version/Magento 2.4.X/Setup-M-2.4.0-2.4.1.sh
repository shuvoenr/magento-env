#!/bin/bash
LOG_DIR_PATH=/var/log/
LOG_FULL_PATH=${LOG_DIR_PATH}Magento_SETUP.log

# -- Log Write /var/log Folder
logWrite(){
  echo "$(date) : $1" >> "$LOG_FULL_PATH"
}

# Swap Storage Create
swapCreate() {
  echo -p "Do you want to create swap [Y/N] : "
  read -r isSwap
  if [ "$isSwap" = "Y" ] || [ "$isSwap" = "y" ]; then
    echo "How Many GB you want as Swap (Recommended Double of the Storage) : "
    read -r swapRam
    printf  "Setting %s GB as swap memory.\n" "$swapRam"
    sudo fallocate -l "$swapRam"G /swapfile
    printf  "Allocate Done.\n"
    sudo chmod 600 /swapfile
    printf  "Permission Changed.\n"
    sudo mkswap /swapfile
    sudo swapon /swapfile
    printf "Swap is up & Run.\n"
    printf "Making the swap space permanent.\n"
    sudo cp /etc/fstab /etc/fstab.bak
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi
}

# -- Install Composer
installComposer() {
  echo "Do you want to install composer? [Y/N] : "
  read -r wantComposerInstall
  if [ "$wantComposerInstall" = "Y" ] || [ "$wantComposerInstall" = "y" ]; then
    # -- Install composer dependent package
    sudo apt install wget php-cli php-zip unzip --assume-yes
    wget -O composer-setup.php https://getcomposer.org/installer
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    composer -V
    # By default composer will install composer 2.X, but Magento 2 still not support that, so we will install 1.10.X Version
    sudo composer self-update --1
  fi
}

printf  "We are starting the process, Cooperate by giving you choice, if you asked for anything.... \n"

# Update assume yes command
sudo apt-get update --assume-yes
sudo apt-get upgrade --assume-yes

# Swap Memory
swapCreate

# Composer Install
installComposer

