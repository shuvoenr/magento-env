#!/bin/bash

# log path you can view later what happen
LOG_FULL_PATH=/var/log/elasicsearch-setup-enviroment.log
LOG_DIR_PATH=/var/log/
ELASTIC_CONFIG_PATH=/etc/elasticsearch/elasticsearch.yml

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

# --------------------- ELASTICSEARCH INSTALL ---------------------#
# --------------------- ELASTICSEARCH INSTALL ---------------------#

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

#Install Elasticsearch Dynamically
installElasticsearch() {
    printf  "${GREEN} Installing... Elasticseach... ${NORMAL}\\n"
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    echo "deb https://artifacts.elastic.co/packages/${1}.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-${1}.x.list
    printf "deb https://artifacts.elastic.co/packages/${1}.x/apt stable main"
    sudo apt update --assume-yes >> "$LOG_FULL_PATH"
    sudo apt install -y elasticsearch --assume-yes >> "$LOG_FULL_PATH"
    sudo /bin/systemctl daemon-reload
    sudo /bin/systemctl enable elasticsearch.service
    sudo systemctl start elasticsearch.service
    # sudo systemctl status elasticsearch.service
    echo "Waiting for ElasticSearch to boot up..."
    sleep 20
    curl -XGET 'localhost:9200/?pretty'
    printf  "${GREEN} Do you want to whitelist IP address?${NORMAL}\\n"
    printf  "${YELLOW} All IP Address Type 1${NORMAL}\\n"
    printf  "${YELLOW} Specific IP Address Type 2${NORMAL}\\n"
    printf  "${YELLOW} Use as Localhost Type 3${NORMAL}\\n"
    read -p ": " whitelistIp
    if [ "$whitelistIp" =  1 ]
    then
        echo  "network.host: 0.0.0.0" >> "$ELASTIC_CONFIG_PATH"
        echo  "discovery.seed_hosts: []" >> "$ELASTIC_CONFIG_PATH"
    elif [ "$whitelistIp" =  2 ]
    then
        printf  "${YELLOW} Enter the Public IP Address from where you going to access?: ${NORMAL}\\n"
        read -p ": " ipAddressWhitelist
        echo  "network.host: ${ipAddressWhitelist}" >> "$ELASTIC_CONFIG_PATH"
        echo  "discovery.seed_hosts: []" >> "$ELASTIC_CONFIG_PATH"
    else
        echo "We will use it as localhost service"
    fi

    #reloading the things
    sudo /bin/systemctl daemon-reload
    sudo systemctl restart elasticsearch.service
    curl -XGET 'localhost:9200/?pretty'
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

#Calling the Method
read -p "Do you want to install Elastic Search [Y/N] : " isElasticWillInstall
if [ "$isElasticWillInstall" = "Y" ] || [ "$isElasticWillInstall" = "y" ]; then
   #Installig Java for Liux
   printf  "${GREEN} Installing Java. ${NORMAL}\\n"
   read -p "Which Java Version you want to setup [only 8 support, otherwise deafult will setup] : " javaVersion
   if [ "$javaVersion" =  8 ];
   then
       installJava8
   else
      installJavaDefault
   fi

   #Installig the Elasticsearch
   printf  "${YELLOW} Elasticsearch Installing.... ${NORMAL}\\n"
   read -p "Which Elasticsearch Version you want to setup [only 5, 6, 7] : " elasicsearchVersion

   if [ "$elasicsearchVersion" =  5 ]
   then
       installElasticsearch 5
   elif [ "$elasicsearchVersion" =  6 ]
   then
      installElasticsearch 6
   elif [ "$elasicsearchVersion" =  7 ]
   then
      installElasticsearch 7
   else
       echo "Skip the Elasticserch Install.."
   fi

   printf  "${YELLOW} Done Elasticsearch Install Successfully.... ${NORMAL}\\n"
else
    printf  "${YELLOW} Elasticsearch Install SKIPPED ${NORMAL}\\n"
fi




# --------------------- REDIS INSTALL ---------------------#
# --------------------- REDIS INSTALL ---------------------#

installRedis() {
    sudo apt-get update --assume-yes
    sudo apt-get upgrade --assume-yes
    sudo apt install redis-server --assume-yes
    sudo systemctl status redis-server --no-pager
    PING_PONG=$(redis-cli "ping")
    if [ "$PING_PONG"="PONG" ];
    then
        printf "PING->PONG Working \\n"
    else
        printf "${RED} I am not working well \\n"
    fi
    printf "${PING_PONG}\\n"
}

getRedisWhiltelistIp () {

    LINETOREPLACE=$(grep -Fxn "bind 127.0.0.1 ::1" /etc/redis/redis.conf | gawk '{print $1}' FS=":")
    sed  -i "${LINETOREPLACE}s/bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf
    return

    # here is a issue like dynamic whitelist not working -- when did we restart redis get stack -- need to fixed
    read -p " :" isExternalWhitelistRedis
    if [ -z "$isExternalWhitelistRedis" ]
    then
        printf "${RED} IP should not be empty\\n"
        getRedisWhiltelistIp
    else
        LINETOREPLACE=$(grep -Fxn "bind 127.0.0.1 ::1" /etc/redis/redis.conf | gawk '{print $1}' FS=":")
        if [ -z "$LINETOREPLACE" ]
        then
            printf "${RED} Something is wrong. Maybe you already change the file. if not then give a issue\\n"
        else
            if [ "$isExternalWhitelistRedis" = "0.0.0.0" ]; then
                printf "$isExternalWhitelistRedis\\n"
                sed  -i "${LINETOREPLACE}s/bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf
            else
                printf "$isExternalWhitelistRedis\\n"
                sed  -i "${LINETOREPLACE}s/bind 127.0.0.1 ::1/bind 127.0.0.1 ${isExternalWhitelistRedis}/" /etc/redis/redis.conf    
            fi
        fi
    fi
}

#Asking for redis install
read -p "Do you want to install Redis on Same Server? [Y/N] :" isInstallRedis
if [ "$isInstallRedis" = "Y" ] || [ "$isInstallRedis" = "y" ]
then
    installRedis
    read -p "Do you want to whitelist external IPs in Redis? [Y/N] :" isExternalIpRedis
    if [ "$isExternalIpRedis" = "Y" ] || [ "$isExternalIpRedis" = "y" ]
    then
        # here is a issue like dynamic whitelist not working -- when did we restart redis get stack
        #printf "Give the IP address
        #  [Option 1 : Multiple IP seprated by whitespace write (do not add 127.0.0.1 or localhost) Example : 192.168.78.44 192.168.77.45 ]
        #  [Option 2 : Single IP write (do not add 127.0.0.1 or localhost) Example : 192.168.78.44 ]
        #  [Option 3 : All IP write Example : 0.0.0.0  ]\\n"
        getRedisWhiltelistIp
        sudo systemctl restart redis.service
        sudo systemctl status redis-server --no-pager
    else
        printf "No changes done, only by localhost (127.0.0.1) you can access that\\n"
    fi
else
    printf "Okay Skipping the Redis Install..\\n"
fi
