#!/bin/bash

# log path you can view later what happen
LOG_FULL_PATH=/var/log/elasicsearch-setup-enviroment.log
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

# All Log write function goes here
logWrite(){
        echo "$(date) : $1" >> "$LOG_FULL_PATH"
}

# Swap Storage Create
swapCreate() {
    read -p "How Many GB you want as Swap (Recommand Double of the Storage) : " swapRam
    printf  "${GREEN} Setting ${swapRam} GB as swap memory. ${NORMAL}\\n"
    sudo fallocate -l ${swapRam}G /swapfile
    printf  "${GREEN} Alocate Done. ${NORMAL}\\n"
    sudo chmod 600 /swapfile
    printf  "${GREEN} Permission Changed. ${NORMAL}\\n"
    sudo mkswap /swapfile
    sudo swapon /swapfile
    printf  "${GREEN} Swap is up & Run. ${NORMAL}\\n"
    printf  "${GREEN} Making the swap space permenent. ${NORMAL}\\n"
    sudo cp /etc/fstab /etc/fstab.bak
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
}

#Java 8 Version install
installJava8() {
    printf  "${GREEN} Installing.. Java 8 ${NORMAL}\\n"
    sudo apt-get update --assume-yes >> "$LOG_FULL_PATH"
    sudo apt install openjdk-8-jdk --assume-yes
    # sudo apt install apt-transport-https openjdk-8-jre-headless
    printf  "${GREEN} Verifyig.... ${NORMAL}\\n"
    java -version
}

#Java Default install
installJavaDefault() {
    printf  "${GREEN} Installing.. Java Default ${NORMAL}\\n"
    sudo apt-get update --assume-yes >> "$LOG_FULL_PATH"
    sudo apt install default-jdk --assume-yes
    printf  "${GREEN} Verifyig.... ${NORMAL}\\n"
    java -version
}

printf  "${YELLOW} we are starting the process, please do response if something is asked to you. ${NORMAL}\\n"
printf  "${GREEN} Updatig.... ${NORMAL}\\n"
# Update assume yes command
sudo apt-get update --assume-yes >> "$LOG_FULL_PATH"
printf  "${GREEN} Updatig Done.... ${NORMAL}\\n"

#Calling the Method
read -p "Do you want to create swap [Y/N] : " isSwap
if [ "$isSwap" = "Y" ] || [ "$isSwap" = "y" ]; then
   swapCreate
fi

#Installig Java for Liux
printf  "${GREEN} Installing Java. ${NORMAL}\\n"
read -p "Which Java Version you want to setup [only 8 support, otherwise deafult will setup] : " javaVersion
if [ "$javaVersion" =  8 ];
then
    installJava8
else
   installJavaDefault
fi
