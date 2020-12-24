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
    wget -O composer-setup.php https://getcomposer.org/installer
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    composer -V
    # By default composer will install composer 2.X, but Magento 2 still not support that, so we will install 1.10.X Version
    sudo composer self-update --1
  fi
}

# -- Install PHP
installPHP() {
  sudo add-apt-repository ppa:ondrej/php
  sudo apt-get update --assume-yes
  sudo apt-get install --assume-yes php7.4-{common,fpm,cli,pdo,mysql,opcache,xml,gd,mysql,intl,mbstring,bcmath,json,iconv,soap,ctype,curl,dom,intl,xsl,zip,sockets}
}

# -- Install Elastic Search
installElasticSearch () {
  echo -p "Want to Install ElasticSearch? [Y/N] : "
  read -r wantElasticSearchInstall
  if [ "$wantElasticSearchInstall" = "Y" ] || [ "$wantElasticSearchInstall" = "y" ]; then
    printf "Installing ElasticSearch...\n"
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    printf "deb https://artifacts.elastic.co/packages/7.x/apt stable main"
    sudo apt update --assume-yes
    sudo apt install -y elasticsearch --assume-yes
    sudo /bin/systemctl daemon-reload
    sudo /bin/systemctl enable elasticsearch.service
    sudo systemctl start elasticsearch.service
    # sudo systemctl status elasticsearch.service
    echo "Waiting for ElasticSearch to boot up..."
    sleep 20
    curl -XGET 'localhost:9200/?pretty'
    printf  "Do you want to whitelist IP address?\n"
    printf  "All IP Address Type, 1\n"
    printf  "Specific IP Address, Type 2\n"
    printf  "Use as Localhost Type, 3\n"
    printf ": "
    read -r whitelistIp
    if [ "$whitelistIp" =  1 ]
    then
        sudo echo "network.host: 0.0.0.0"
        sudo echo "discovery.seed_hosts: []"
    elif [ "$whitelistIp" =  2 ]
    then
        printf  "Enter the Public IP Address from where you going to access? : \n"
        read -r ipAddressWhitelist
        sudo echo "network.host: ${ipAddressWhitelist}"
        sudo echo "discovery.seed_hosts: []"
    else
        echo "We will use it as localhost service"
    fi

    #reloading the things
    sudo /bin/systemctl daemon-reload
    sudo systemctl restart elasticsearch.service
    curl -XGET 'localhost:9200/?pretty'
  fi
}

printf  "We are starting the process, Cooperate by giving you choice, if you asked for anything.... \n"

# Update assume yes command
sudo apt-get update --assume-yes
sudo apt-get upgrade --assume-yes
sudo apt-get install curl zip unzip --assume-yes

# Swap Memory
swapCreate

# Composer Install
installComposer

# install PHP
installPHP

# install Elastic Search
installElasticSearch

