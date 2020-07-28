#!/bin/bash



# log path
LOG_FULL_PATH=/var/log/magento2-setup-enviroment.log
LOG_DIR_PATH=/var/log/

# Temporary colors of tput
BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
NORMAL="$(tput sgr0)"

# All function goes here
logWrite(){
        echo "$(date) : $1" >> "$LOG_FULL_PATH"
}

printf  "${YELLOW} Adding the Repositoy. ${NORMAL}\\n"
sudo apt-add-repository ppa:ondrej/php

printf  "${YELLOW} All ready for setting up things for you. Wait for the magic within few moment. ${NORMAL}\\n"

# showing logging path
printf "${GREEN} All install log will be save on ${LOG_FULL_PATH}${NORMAL}\\n"

# Checking directory exist or not
if [ ! -d "$LOG_DIR_PATH" ]
    then
        printf  "${YELLOW} ${LOG_DIR_PATH} directory not found.\\n"
        printf  "${GREEN} Creating this directory.... ${NORMAL}\\n"
        sudo mkdir "$LOG_DIR_PATH"
        printf  "${GREEN} Directory Created. ${NORMAL}\\n"
fi

#Checking file exist or not
if [ ! -f "$LOG_FULL_PATH" ]
    then
        printf  "${YELLOW} $LOG_FULL_PATH file not found.\\n"
        printf  "${GREEN} Creating the file.... ${NORMAL}\\n"
        sudo touch "$LOG_FULL_PATH"
        sudo chmod 777 "$LOG_FULL_PATH"
        printf  "${GREEN} File is Created. ${NORMAL}\\n"
fi

logWrite "Setup process is started..."
logWrite "Configuring Magento 2 Environment with PHP 7.1 | Apache2 | MySQL"
printf  "${YELLOW} Configuring Magento 2 Environment with PHP 7.1 | Apache2 | MySQL. ${NORMAL}\\n"

# Update assume yes command
sudo apt-get update --assume-yes >> "$LOG_FULL_PATH"

# Installing LAMP stack
printf  "${YELLOW} Installing LAMP Stack. ${NORMAL}\\n"
logWrite "Installing LAMP Stack."

    # Installing Apache2
    printf  "${YELLOW} Checking Apache already install or not. ${NORMAL}\\n"
    logWrite "Checking Apache already install or not."
    if [ -d "/etc/apache2" ]
        then
            printf  "${YELLOW} Apache is Already installed ${NORMAL}\\n"
            logWrite "Apache is Already installed."
        else
            printf  "${YELLOW} Apache is not installed. Installing it.... ${NORMAL}\\n"
            logWrite "Apache is not installed. Installing it...."
            sudo apt-get install apache2 --assume-yes
            logWrite "Apache Installed Successful"
            printf  "${GREEN} Apache is Installed Successfully.... ${NORMAL}\\n"

            #Enable the Apache rewrite module
            sudo a2enmod rewrite
            printf  "${GREEN} Enabling Rewrite Module.. ${NORMAL}\\n"
            logWrite "Enabling Rewrite Module.."

            #If not start, generally it is auto start
            sudo sudo systemctl start apache2
            printf  "${GREEN} Enabling Auto Start Apache 2. ${NORMAL}\\n"
            logWrite "Enabling Auto Start Apache 2"

            #Enable the Apache rewrite module
            sudo sudo systemctl enable apache2
            printf  "${GREEN} Force Enabling apache2 Module.. ${NORMAL}\\n"
            logWrite "Force Enabling apache2 Module.."
    fi

    # Installing PHP 7.1
    printf  "${YELLOW} Installing PHP.... ${NORMAL}\\n"
    logWrite "Installing PHP...."
    sudo add-apt-repository ppa:ondrej/php -y >> "$LOG_FULL_PATH"
    printf  "${GREEN} Repository Added Successfully.... ${NORMAL}\\n"
    sudo apt-get update --assume-yes
    sudo apt install --assume-yes php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring
    sudo apt install --assume-yes php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql
    sudo apt install --assume-yes php7.1-cli php7.1-zip php7.1-curl php7.1-mcrypt php7.1-bcmath
    sudo apt install --assume-yes php7.1-cgi php7.1-fpm php7.1-cli
    sudo service apache2 restart
    # if you want to add cgi fpm or cli also write following uncomment following line if commented
    sudo apt install --assume-yes php7.1-cgi php7.1-fpm php7.1-cli
    printf  "${GREEN} All PHP Module Added Successfully.... ${NORMAL}\\n"
    logWrite "All PHP Module Added Successfully...."
